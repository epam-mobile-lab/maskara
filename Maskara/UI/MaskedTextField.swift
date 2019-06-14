//
//  UIMaskara.swift
//  Maskara
//
//  Created by Evgeny Kamyshanov on 10/06/2019.
//  Copyright © 2019 EPAM Systems. All rights reserved.
//

import Foundation
import UIKit

open class MaskedTextField: UITextField, UITextFieldDelegate {

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    func setup() {
        autocorrectionType = .no
        super.delegate = self
    }

    open var maskPattern: String? {
        didSet {
            guard let maskPattern = maskPattern, let editor = try? MaskedTextEditor(maskPattern: maskPattern) else {
                self.editor = nil
                return
            }
            self.editor = editor
        }
    }

    private var editor: MaskedTextEditor?
    public private(set) var extractedText: String = ""
//    private(set) var partial: Bool = true

    override open var delegate: UITextFieldDelegate? {
        get { return internalDelegate }
        set { internalDelegate = newValue }
    }

    // MARK: - Implementation

    private var internalDelegate: UITextFieldDelegate?

    override open func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        guard let editor = editor, result else {
            return result
        }

        if text?.isEmpty ?? true {
            text = editor.text
        }

        if let cursorPosition = position(from: beginningOfDocument, offset: 0) {
            selectedTextRange = textRange(from: cursorPosition, to: cursorPosition)
        }

        return true
    }
    
    override open func deleteBackward() {
        //TODO: just swallow?
    }

    override open func paste(_ sender: Any?) {
        if let string = UIPasteboard.general.string, let selectedRange = self.selectedTextRange {
            _ = textField(self, shouldChangeCharactersIn: normalizedRange(from: selectedRange), replacementString: string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        }
    }

    override open func copy(_ sender: Any?) {
        if let selectedRange = self.selectedTextRange {
            let range = normalizedRange(from: selectedRange)
            let extract = editor?.extractedText(from: range.location, length: range.length) ?? ""
            UIPasteboard.general.string = extract
        }
    }

    override open func cut(_ sender: Any?) {
        copy(nil)
        if let selectedRange = self.selectedTextRange {
            _ = textField(self, shouldChangeCharactersIn: normalizedRange(from: selectedRange), replacementString: "")
        }
    }

    // MARK: - Implementation

    internal final func normalizedRange(from textRange: UITextRange) -> NSRange {
        let start = offset(from: beginningOfDocument, to: textRange.start)
        let end = offset(from: beginningOfDocument, to: textRange.end)
        return NSRange(location: min(start, end), length: abs(end - start))
    }

    // MARK: UITextFieldDelegate

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return internalDelegate?.textFieldShouldBeginEditing?(textField) ?? true
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        internalDelegate?.textFieldDidBeginEditing?(textField)
    }

    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return internalDelegate?.textFieldShouldEndEditing?(textField) ?? true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        internalDelegate?.textFieldDidEndEditing?(textField)
    }

    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        internalDelegate?.textFieldDidEndEditing?(textField, reason: reason)
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let editor = editor else {
            return false
        }

        do {
            let cursorPosition = try editor.replace(from: range.location, length: range.length, replacementString: string)
            text = editor.text
        
            if let cursorPosition = position(from: beginningOfDocument, offset: cursorPosition) {
                selectedTextRange = textRange(from: cursorPosition, to: cursorPosition)
            }

            extractedText = editor.extractedText
        } catch {
            //TODO: propagate errors here
            return false
        }

        _ = internalDelegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string)
        return false
    }

    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return internalDelegate?.textFieldShouldClear?(textField) ?? true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return internalDelegate?.textFieldShouldReturn?(textField) ?? true
    }

}

