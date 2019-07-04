//
//  MaskaraTextEditor.swift
//  Maskara
//
//  Created by Evgeny Kamyshanov on 11/06/2019.
//  Copyright © 2019 EPAM Systems. All rights reserved.
//

import Foundation

open class MaskedTextEditor {

    public private(set) var matcher: MaskMatcher
    public private(set) var textualMask: TextualMask

    public private(set) var text: String = ""
    public private(set) var transformedText: String = ""
    
    public var extractedText: ExtractResult? {
        guard let extractResult = try? matcher.extract(from: transformedText) else {
            return nil
        }
        return extractResult
    }

    public init(maskPattern: String) throws {
        self.textualMask = try TextualMask(with: maskPattern)
        self.matcher = MaskMatcher(mask: self.textualMask, options: [.optimisticMatch])
        self.text = matcher.renderMask()
    }

    /// Tries to replace a substring in `self.text` starting from `position` and of `length`
    /// with `replacementString` in accordance with mask given.
    /// 
    /// The remainings of the `self.text` will be shifted if possible.
    /// All the optional mask symbols in shifted part will be lost in the shift.
    /// Mimics `UITextField` behaviour, i.e. uses the function for all type of editing:
    ///   - inserting and replacing are strightforward
    ///   - deleting is a replacement of a substring of length `length` with an empty string from `position`
    ///
    /// - Parameters:
    ///   - position: starting position for replacement.
    ///   - length: a length of a substring being replaced
    ///   - string: the replacement being inserted starting from `position`
    /// - Returns: new position for a [sequential] insertion, i.e. literaly a "cursor" position
    /// - Throws: throws MaskMatcher.MatchError if insertion is invalid
    public func replace(from position: Int, length: Int, replacementString string: String) throws -> Int {

        let (left, _) = text.split(from: position, length: length)
        let (_, right) = transformedText.split(from: position, length: length)

        // Dry run on the left side (including part which is about to be changed),
        // should always be ok since 'left' is already in text, so just move state to a proper position
        _ = try matcher.match(sample: text.left(upperBound: position + length))

        // try extract the real data from right remainings before it is being shifted
        var newRight = ""
        switch try matcher.extract(from: right, resetMask: false)  {
        case .complete(let extract), .partial(let extract):
            newRight = extract
        }

        // transfrom to text with inserted value and get the cursor position
        let newTransform = try matcher.transform(sample: left + string)
        let newCursorPosition = newTransform.count

        // add the right transformed string
        transformedText = newTransform + (try matcher.transform(sample: newRight, resetMask: false))

        text = transformedText + matcher.renderMask(resetMask: false)

        return newCursorPosition
    }

    public func extractedText(from position: Int, length: Int) -> String {
        let left = transformedText.left(upperBound: position)
        let copied = transformedText.substring(from: position, length: length)
        guard let _ = try? matcher.match(sample: left), let extractResult = try? matcher.extract(from: copied, resetMask: false) else {
            return ""
        }
        switch extractResult {
        case .complete(let extract), .partial(let extract):
            return extract
        }
    }

}
