//
//  DisplayState.swift
//  

import Foundation

public enum DisplayState {
    case clear
    case suggestUpdate
    case forceUpdate
    case downForMaintenance
    case developmentFailure(String)
}
