//
//  File.swift
//  
//
//  Created by Nigel Brooke on 2020-10-13.
//

import Foundation

// note: protocol is synchronous because it is always called on a background thread, any one mocking it needs to
// make sure the call is thread safe
public protocol URLFetcher {
    func data(for: URL) -> Data?
}

public struct NetworkURLFetcher: URLFetcher {
    public init() {
        //...
    }

    public func data(for url: URL) -> Data? {
        return try? Data(contentsOf: url)
    }
}
