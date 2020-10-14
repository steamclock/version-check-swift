//
//  DisplayState.swift
//  

import Foundation

public enum DisplayState: Equatable {
    case clear
    case suggestUpdate
    case forceUpdate
    case downForMaintenance
    case developmentFailure(String)
}
