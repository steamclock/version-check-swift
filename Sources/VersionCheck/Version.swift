//
//  Version.swift
//

import Foundation

let marketingRegex = try! NSRegularExpression(pattern:#"([0-9\.]+)(.*)"#)

public struct Version: Equatable, Comparable {
    let marketingComponents: [Int]
    let build: Int?
    let additionalText: String?
    let isDevelopment: Bool

    public var description: String {
        let version = marketingComponents.map { "\($0)" }.joined(separator: ".")
        let buildText = build == nil ? "" : "@\(build ?? 0)"
        return version + (additionalText ?? "") + buildText
    }

    // Actual main parsing / initialization based on an optional marketing and build version. Kept private because any external caller should
    // always specify at least some text
    private init(optMarketing marketing: String?, optBuild build: String?) throws {
        // zero is a special build number that indicates it's a development build, flag
        // that separately rather than leaving it as a 0 in the build number
        if build == "0" {
            self.build = nil
            self.isDevelopment = true
        } else {
            self.build = Int(build ?? "")
            self.isDevelopment = false
        }

        if let marketing = marketing {
            // separate additional text from numeric marketing versions
            let splitMarketing = marketingRegex.captureGroups(in: marketing)
            additionalText = splitMarketing.first?[checked: 2]
            let numericMarketing = splitMarketing.first?[checked: 1] ?? ""

            // numeric portion of marketing version can't start or end with a dot, which regex doesn't capture
            if numericMarketing.first == "." || numericMarketing.last == "." {
                throw VersionCheckError.invalidVersionString
            }

            // turn marketing components into actual numbers
            let components = (splitMarketing.first?[checked: 1] ?? "").split(separator: ".")
            marketingComponents = try components.map {
                if let value = Int($0) {
                    return value
                }

                throw VersionCheckError.invalidVersionString
            }
        } else {
            additionalText = nil
            marketingComponents = []
        }

        if marketingComponents.isEmpty && build == nil {
            throw VersionCheckError.invalidVersionString
        }
    }

    public init(string: String) throws {
        if string.first == "@" {
            try self.init(build: String(string.dropFirst()))
        } else {
            let marketingAndBuild = string.split(separator: "@")

            if marketingAndBuild.isEmpty || marketingAndBuild.count > 2 {
                throw VersionCheckError.invalidVersionString
            }

            var marketing: String? = String(marketingAndBuild.first ?? "")

            if marketing == "" {
                marketing = nil
            }

            let build: String? = marketingAndBuild.count == 2 ? String(marketingAndBuild[1]) : nil

            try self.init(optMarketing: marketing, optBuild: build)
        }
    }

    public init(marketing: String, build: String? = nil) throws {
        try self.init(optMarketing: marketing, optBuild: build)
    }

    public init(build: String) throws {
        try self.init(optMarketing: nil, optBuild: build)
    }

    public static func == (_ lhs: Version, _ rhs: Version) -> Bool {
        // assume that all missing components are zeros
        let components = Zip2WithNilPadding(lhs.marketingComponents, rhs.marketingComponents).map { ($0.0 ?? 0, $0.1 ?? 0) }

        // check that all marketing components are equal
        let marketingMatches = components.reduce(true) {
            return $0 && ($1.0 == $1.1)
        }

        // overall equality is marketing equality and build equality
        return marketingMatches && lhs.build == rhs.build
    }

    public static func < (_ lhs: Version, _ rhs: Version) -> Bool {
        if lhs.marketingComponents.isEmpty && rhs.marketingComponents.isEmpty {
            // These should never be nil in this situation, or we should have got a parse error earlier
            return lhs.build! < rhs.build!
        }

        // paired components, padded with zeros
        let components = Zip2WithNilPadding(lhs.marketingComponents, rhs.marketingComponents).map { ($0.0 ?? 0, $0.1 ?? 0) }

        // check if pairwise version components compare differntly
        for element in components {
            if element.0 < element.1 {
                return true
            }

            if element.0 > element.1 {
                return false
            }
        }

        // if we made it here, marketing versions must be equal

        // Development builds are always considered to be "higher" then any
        // specific numerical builds, so check of the "development-ness" if the
        // versions doesn't match and handle separately
        if !lhs.isDevelopment && rhs.isDevelopment {
            return true
        }

        if lhs.isDevelopment && !rhs.isDevelopment {
            return false
        }

        // marketing version are same and whether or not they are development builds doesn't matter
        // just compare build numbers
        return ((lhs.build ?? 0) < (rhs.build ?? 0))
    }
}
