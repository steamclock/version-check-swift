//
//  Status.swift
//  

import Foundation

public enum Status: Equatable {
    case unknown
    case fetchFailure
    case versionAllowed
    case versionDisallowed
}
