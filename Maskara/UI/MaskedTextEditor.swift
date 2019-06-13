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
    
    public var extractedText: String {
        guard let extractResult = try? matcher.extract(from: transformedText) else {
            return ""
        }
        switch extractResult {
            case .complete(let extract), .partial(let extract):
                return extract
        }
    }

    public init(maskPattern: String) throws {
        self.textualMask = try TextualMask(with: maskPattern)
        self.matcher = MaskMatcher(mask: self.textualMask, options: [.optimisticMatch])
        self.text = matcher.renderMask()
    }

    public func replace(from position: Int, length: Int, replacementString string: String) throws -> Int {

        let (left, right) = transformedText.split(from: position, length: length)

        // should always be ok since 'left' is already in text, so just move state to a proper position
        _ = try matcher.match(sample: transformedText.left(upperBound: position + length))

        // try extract the real data from right remainings before it is being shifted
        var newRight = ""
        if let extractResult = try? matcher.extract(from: right, resetMask: false) {
            switch extractResult {
            case .complete(let extract), .partial(let extract):
                newRight = extract
            }
        }

        // transfrom to text with inserted value and get the cursor position
        let newTransform = try matcher.transform(sample: left + string)
        let newCursorPosition = newTransform.count

        // add the right transformed string
        transformedText = newTransform + (try matcher.transform(sample: newRight, resetMask: false))

        text = transformedText + matcher.renderMask(resetMask: false)

        return newCursorPosition
    }

}
