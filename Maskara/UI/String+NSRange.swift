//
//  String+NSRange.swift
//  Maskara
//
//  Created by Evgeny Kamyshanov on 10/06/2019.
//  Copyright © 2019 EPAM Systems. All rights reserved.
//

import Foundation

extension String {

    public func replacedSubstring(from location: Int, length: Int, with string: String) -> String {
        let lowerBound = min(location, location + length)
        let upperBound = max(location, location + length)

        if lowerBound >= count {
            return self + string
        }

        var resultingString = ""

        for (index, char) in enumerated() {
            if index < location {
                resultingString.append(char)
                continue
            }
            if index == location {
                resultingString.append(string)
            }
            if index >= location && index < upperBound {
                continue
            }
            if index >= upperBound {
                resultingString.append(char)
            }
        }

        return resultingString
    }

    public func replacedSubstring(in range: NSRange, with string: String) -> String {
        if range.lowerBound >= count {
            return self + string
        }

        var resultingString = ""

        for (index, char) in enumerated() {
            if index < range.location {
                resultingString.append(char)
                continue
            }
            if index == range.location {
                resultingString.append(string)
            }
            if index >= range.location && index < range.upperBound {
                continue
            }
            if index >= range.upperBound {
                resultingString.append(char)
            }
        }

        return resultingString
    }
    
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
