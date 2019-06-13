//
//  String+NSRange.swift
//  Maskara
//
//  Created by Evgeny Kamyshanov on 10/06/2019.
//  Copyright © 2019 EPAM Systems. All rights reserved.
//

import Foundation

extension String {

    public func split(from location: Int, length: Int) -> (String, String) {
        let lowerBound = min(location, location + length)
        let upperBound = max(location, location + length)
        
        let leftBound = index(startIndex, offsetBy: min(count, lowerBound))
        let rightBound = index(startIndex, offsetBy: min(upperBound, count))
        return (String(self[..<leftBound]), String(self[rightBound...]))
    }

    public func left(upperBound: Int) -> String {
        let rightBound = index(startIndex, offsetBy: min(upperBound, count))
        return String(self[..<rightBound])
    }
}
