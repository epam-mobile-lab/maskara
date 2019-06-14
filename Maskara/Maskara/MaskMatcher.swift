//
//  Maskara.swift
//  Maskara
//
//  Created by Evgeny Kamyshanov on 06/06/2019.
//  Copyright © 2019 EPAM Systems. All rights reserved.
//

import Foundation

public enum MatchResult {
    case partial
    case complete
}

public enum ExtractResult {
    case partial(String)
    case complete(String)
}

open class MaskMatcher {

    public enum MatchError: Error {
        case maskEnded(Int)
        case symbolMismatch(Int, Mask.State)
        case transformFailed(Int)
    }

    public enum MatchOption {
        case optimisticMatch
    }

    public let mask: Mask

    private let optimisticMatch: Bool

    init(mask: Mask, options: [MatchOption] = []) {
        self.mask =  mask
        self.optimisticMatch = options.contains(.optimisticMatch)
    }

    open func match(sample: String, resetMask: Bool = true) throws -> MatchResult {
        if resetMask {
            mask.reset()
        }

        for (index, char) in sample.enumerated() {
            try evaluate(char: char, at: index)
        }

        return mask.complete ? .complete : .partial
    }

    open func transform(sample: String, resetMask: Bool = true) throws -> String {
        if resetMask {
            mask.reset()
        }

        var resultingString = ""

        for (index, char) in sample.enumerated() {
            resultingString += try transform(char: char, at: index)
        }

        return resultingString
    }

    open func extract(from sample: String, resetMask: Bool = true) throws -> ExtractResult {
        if resetMask {
            mask.reset()
        }

        var resultingString = ""

        for (index, char) in sample.enumerated() {
            if let extractedChar = try extract(char: char, at: index) {
                resultingString.append(extractedChar)
            }
        }

        return mask.complete ? .complete(resultingString) : .partial(resultingString)
    }

    open func renderMask(resetMask: Bool = true) -> String {
        if resetMask {
            mask.reset()
        }

        var resultingString = ""

        while !mask.complete {
            if let char = mask.renderNextStep() {
                resultingString.append(char)
            }
        }

        return resultingString
    }

    open func isStateExtractable(state: Mask.State) -> Bool {
        switch state {
        case .number, .letter:
            return true
        case .or(let left, let right):
            return isStateExtractable(state: left) || isStateExtractable(state: right)
        default:
            return false
        }
    }

    // MARK: implementation

    private final func isAlfanumeric(state: Mask.State) -> Bool {
        switch state {
        case .number, .letter:
            return true
        default:
            return false
        }
    }

    private final func extract(char: Character, at index: Int) throws -> Character? {
        switch mask.onChar(char) {
        case .ok where isStateExtractable(state: mask.getCurrentState()):
            return char
        case .endReached:
            if !optimisticMatch {
                throw MatchError.maskEnded(index)
            }
        case .charMismatch(let state) where optimisticMatch:
            if isAlfanumeric(state: state) {
                throw MatchError.symbolMismatch(index, state)
            }
            return try extract(char: char, at: index)
        case .charMismatch(let expectedState):
            throw MatchError.symbolMismatch(index, expectedState)
        default:
            return nil
        }
        return nil
    }

    private func transform(char: Character, at index: Int) throws -> String {
        let result = mask.transformChar(char)
        switch result.1 {
        case .ok:
            if let transformedChar = result.0 {
                return String(transformedChar)
            } else {
                throw MatchError.transformFailed(index)
            }
        case .endReached:
            if optimisticMatch {
                return ""
            }
            throw MatchError.maskEnded(index)
        case .charMismatch(let state) where optimisticMatch:
            if isAlfanumeric(state: state) {
                throw MatchError.symbolMismatch(index, state)
            }
            if let transformedChar = result.0 {
                return String(transformedChar) + (try transform(char: char, at: index))
            } else {
                return try transform(char: char, at: index)
            }
        case .charMismatch(let expectedState):
            throw MatchError.symbolMismatch(index, expectedState)
        }
    }

    private func evaluate(char: Character, at index: Int) throws {
        switch mask.onChar(char) {
        case .ok:
            return
        case .endReached:
            throw MatchError.maskEnded(index)
        case .charMismatch(let expectedState):
            if optimisticMatch {
                try evaluate(char: char, at: index)
            } else {
                throw MatchError.symbolMismatch(index, expectedState)
            }
        }
    }
}
