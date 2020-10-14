//
//  File.swift
//  

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (checked index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
