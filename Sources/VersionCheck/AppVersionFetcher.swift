//
//  AppVersionFetcher.swift
//  

import Foundation

public protocol AppVersionFetcher {
    var marketing: String? { get }
    var build: String? { get }
}

public struct IOSVersionFetcher: AppVersionFetcher {
    public init() {
        //...
    }

    public var marketing: String? { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String }
    public var build: String? { Bundle.main.infoDictionary?["CFBundleVersion"] as? String }
}
