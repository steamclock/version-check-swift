//
//  NSRegularExpression+CaptureGroups.swift
//  

import Foundation

extension NSRegularExpression {
    func captureGroups(in text: String) -> [[String]] {
        let matches = self.matches(in: text, range: NSRange(text.startIndex..., in: text))
        return matches.map { match in
            return (0..<match.numberOfRanges).map {
                let rangeBounds = match.range(at: $0)
                guard let range = Range(rangeBounds, in: text) else {
                    return ""
                }
                return String(text[range])
            }
        }
    }
}
