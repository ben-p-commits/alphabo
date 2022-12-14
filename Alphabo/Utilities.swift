//
//  Utilities.swift
//  Alphabo
//
//  Created by Benjamin Palmer on 12/6/22.
//

import Foundation
import SwiftUI
import Gradients

extension ClosedRange where Bound == UnicodeScalar {
    func toArray() -> [UnicodeScalar] {
        (lowerBound.value...upperBound.value).compactMap { UnicodeScalar($0) }
    }
}

extension ClosedRange where Bound == String {
    func toArray() -> [UnicodeScalar]? {
        guard let lower = lowerBound.first?.unicodeScalars.first,
              let upper = upperBound.first?.unicodeScalars.first else { return nil }
        return (lower...upper).toArray()
    }
}

// for easy throwing
extension String: Error {}

import SwiftUI

extension Color {
    static var random: Color {
        
        let h = CGFloat.random(in: 0.1...1),
            s = CGFloat.random(in: 0.4...1),
            v = CGFloat.random(in: 0.5...1)
        
        let color = UIColor(hue: h, saturation: s, brightness: v, alpha: 1)
        return Color(color)
    }
}

