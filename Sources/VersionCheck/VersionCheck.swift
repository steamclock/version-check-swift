//
//  VersionCheck.swift
//

import Foundation

public class VersionCheck {
    public var appVersion: Version?

    public private(set) var status: Status {
        didSet {
            statusHandler?(status)
        }
    }

    public private(set) var displayState: DisplayState {
        didSet {
            displayHandler?(displayState)
        }
    }

    public private(set) var lastVersionData: VersionData?

    private let url: String
    private let displayHandler: ((DisplayState) -> Void)?
    private let statusHandler: ((Status) -> Void)?
    private let jsonFormatConverter: ((Data) -> VersionData)?
    private let appVersionFetch: AppVersionFetcher
    private let urlFetch: URLFetcher

    private let developmentMode: Bool

    public init(url: String,
                displayHandler: ((DisplayState) -> Void)? = nil,
                statusHandler: ((Status) -> Void)?,
                jsonFormatConverter: ((Data) -> VersionData)?,
                appVersionFetch: AppVersionFetcher = IOSVersionFetcher(),
                urlFetch: URLFetcher = NetworkURLFetcher()) {
        self.url = url
        self.displayHandler = displayHandler
        self.statusHandler = statusHandler
        self.jsonFormatConverter = jsonFormatConverter
        self.appVersionFetch = appVersionFetch
        self.urlFetch = urlFetch

        status = .unknown
        displayState = .clear

        if let build = appVersionFetch.build,
           let marketing = appVersionFetch.marketing,
           let version = try? Version(marketing: marketing, build: build) {
            developmentMode = build == "0"
            appVersion = version
        } else {
            developmentMode = appVersionFetch.build == "0"
            appVersion = nil
        }

        performVersionCheck()
    }

    public func performVersionCheck() {
        guard let url = URL(string: self.url) else {
            status = .fetchFailure
            warn("Invalid version check URL")
            return
        }

        DispatchQueue.global().async {
            guard let jsonData = self.urlFetch.data(for: url) else {
                DispatchQueue.main.async {
                    self.status = .fetchFailure
                    self.warn("Could not fetch version check data from server")
                }
                return
            }

            DispatchQueue.main.async {
                var versionData: VersionData?

                if let jsonFormatConverter = self.jsonFormatConverter {
                    versionData = jsonFormatConverter(jsonData)
                } else {
                    let decoder = JSONDecoder()
                    versionData = try? decoder.decode(VersionData.self, from: jsonData)
                }

                if let versionData = versionData {
                    self.validateVersion(versionData)
                } else {
                    self.status = .fetchFailure
                    self.warn("Could not decode server version response")
                }
            }
        }
    }

    func warn(_ message: String) {
        if self.developmentMode {
            self.displayState = .developmentFailure(message)
        }
    }

    func validateVersion(_ versionData: VersionData) {
        lastVersionData = versionData

        guard let appVersion = self.appVersion else {
            status = .fetchFailure
            warn("Could not fetch / parse app version string")
            return
        }

        if versionData.serverForceVersionFailure == true {
            status = .versionDisallowed
            displayState = .forceUpdate
            return
        }

        if let minimumVersion = versionData.ios?.minimumVersion {
            if appVersion < minimumVersion {
                status = .versionDisallowed
                displayState = .forceUpdate
                return
            }
        } else {
            warn("No minimum version specified in server version data")
        }

        if let blockedVersions = versionData.ios?.blockedVersions {
            for blocked in blockedVersions {
                if blocked ~= appVersion {
                    status = .versionDisallowed
                    displayState = .forceUpdate
                    return
                }
            }
        }

        if let latestTestVersion = versionData.ios?.latestTestVersion {
            if appVersion < latestTestVersion {
                status = .versionAllowed
                displayState = .suggestUpdate
                return
            }
        }

        if versionData.serverMaintenance == true {
            status = .versionAllowed // must be if we have made it here
            displayState = .downForMaintenance
            return
        }

        status = .versionAllowed
        displayState = .clear
    }
}
