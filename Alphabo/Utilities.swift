//
//  Utilities.swift
//  Alphabo
//
//  Created by Benjamin Palmer on 12/6/22.
//

import Foundation

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
