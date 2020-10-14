//
//  VersionData.swift
//  

import Foundation

public struct PlatformVersionData: Codable {
    public let minimumVersion: Version?
    public let blockedVersions: [Version]?
    public let currentVersion: Version?

    public init(minimumVersion: Version?, blockedVersions: [Version]?, currentVersion: Version?) {
        self.minimumVersion = minimumVersion
        self.blockedVersions = blockedVersions
        self.currentVersion = currentVersion
    }
}

public struct VersionData: Codable {
    public let ios: PlatformVersionData?
    public let serverForceVersionFailure: Bool?
    public let serverMaintenance: Bool?

    public init(ios: PlatformVersionData?, serverForceVersionFailure: Bool?, serverMaintenance: Bool?) {
        self.ios = ios
        self.serverForceVersionFailure = serverForceVersionFailure
        self.serverMaintenance = serverMaintenance
    }
}
