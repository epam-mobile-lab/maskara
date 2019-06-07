//
//  MaskaraEditorTests.swift
//  MaskaraTests
//
//  Created by Evgeny Kamyshanov on 11/06/2019.
//  Copyright © 2019 EPAM Systems. All rights reserved.
//

import Foundation
import Nimble
import Quick

@testable import Maskara

class MaskaraEditorTests: QuickSpec {
    override func spec() {

        let mask = "+?7|8(DDD)DDD-?DD-?DD"
        var editor: MaskaraTextEditor!

        beforeEach {
            editor = try! MaskaraTextEditor(maskPattern: mask)
        }

        describe("Editor") {

            it("should allow strightforward ltr input") {
                let position = try? editor.replace(from: 0, length: 0, replacementString: "1")
                expect(editor.text).to(equal("7(1__)_______"))
                expect(position).to(equal(3))
            }
            
            it("should allow input") {
                var position = try! editor.replace(from: 0, length: 0, replacementString: "1")
                position = try! editor.replace(from: position, length: 0, replacementString: "2")
                position = try! editor.replace(from: position, length: 0, replacementString: "3")
                expect(editor.text).to(equal("7(123)_______"))
                expect(position).to(equal(5))
                let plusPosition = try? editor.replace(from: 0, length: 0, replacementString: "+")
                expect(editor.text).to(equal("+7(123)_______"))
                expect(plusPosition).to(equal(1))
            }

            it("should allow insertion with optionals") {
                let position = try? editor.replace(from: 0, length: 0, replacementString: "+7(123)456-78-90")
                expect(editor.text).to(equal("+7(123)456-78-90"))
                expect(position).to(equal(16))
            }

            it("should allow insertion before symbolic element") {
                var position = try! editor.replace(from: 0, length: 0, replacementString: "123")
                position = try! editor.replace(from: position, length: 0, replacementString: "4")
                expect(editor.text).to(equal("7(123)4______"))
                expect(position).to(equal(7))
            }
            
            it("should allow deletion from arbitrary position") {
                var position = try? editor.replace(from: 0, length: 0, replacementString: "1234")
                expect(editor.text).to(equal("7(123)4______"))
                expect(position).to(equal(7))
                position = try! editor.replace(from: 4, length: 1, replacementString: "")
                expect(editor.text).to(equal("7(124)_______"))
                expect(position).to(equal(4))
            }

            it("should allow massive deletion from arbitrary position") {
                var position = try? editor.replace(from: 0, length: 0, replacementString: "123456")
                expect(editor.text).to(equal("7(123)456____"))
                position = try! editor.replace(from: 4, length: 4, replacementString: "")
                expect(editor.text).to(equal("7(126)_______"))
                expect(position).to(equal(4))
            }
            
            it("should allow an insertion of optional symbols") {
                _ = try? editor.replace(from: 0, length: 0, replacementString: "12345678")
                expect(editor.text).to(equal("7(123)45678__"))
                let position = try? editor.replace(from: 9, length: 0, replacementString: "-")
                expect(editor.text).to(equal("7(123)456-78__"))
                expect(position).to(equal(10))
            }
            
            it("should not allow illegal symbols") {
                let position = try! editor.replace(from: 0, length: 0, replacementString: "1")
                expect(editor.text).to(equal("7(1__)_______"))
                expect(position).to(equal(3))
                expect { try editor.replace(from: position, length: 0, replacementString: "A") }.to(throwError())
            }

            it("should allow extraction") {
                _ = try? editor.replace(from: 0, length: 0, replacementString: "123456")
                expect(editor.text).to(equal("7(123)456____"))
                expect(editor.extractedText).to(equal("123456"))
                _ = try! editor.replace(from: 4, length: 4, replacementString: "")
                expect(editor.text).to(equal("7(126)_______"))
                expect(editor.extractedText).to(equal("126"))
            }

        }
        
        describe("String manipulation") {
            it("should insert substring in range") {
                let string = "1234567890"
                expect(string.replacedSubstring(in: NSRange(location: 0, length: 2), with: "AB")).to(equal("AB34567890"))
                expect(string.replacedSubstring(in: NSRange(location: 7, length: 3), with: "A")).to(equal("1234567A"))
                expect(string.replacedSubstring(in: NSRange(location: 8, length: 0), with: "ABC")).to(equal("12345678ABC90"))
                expect(string.replacedSubstring(in: NSRange(location: 8, length: 3), with: "A")).to(equal("12345678A"))
                expect(string.replacedSubstring(in: NSRange(location: 10, length: 2), with: "ABC")).to(equal("1234567890ABC"))
                
                expect(string.replacedSubstring(from: 0, length: 2, with: "AB")).to(equal("AB34567890"))
                expect(string.replacedSubstring(from: 7, length: 3, with: "A")).to(equal("1234567A"))
                expect(string.replacedSubstring(from: 8, length: 0, with: "ABC")).to(equal("12345678ABC90"))
                expect(string.replacedSubstring(from: 8, length: 3, with: "A")).to(equal("12345678A"))
                expect(string.replacedSubstring(from: 10, length: 2, with: "ABC")).to(equal("1234567890ABC"))
            }
            
            it("should split string by insertion") {
                let string = "1234567890"
                
                var (left, right) = string.split(from: 0, length: 2)
                expect(left).to(equal(""))
                expect(right).to(equal("34567890"))

                (left, right) = string.split(from: 7, length: 3)
                expect(left).to(equal("1234567"))
                expect(right).to(equal(""))

                (left, right) = string.split(from: 4, length: 10)
                expect(left).to(equal("1234"))
                expect(right).to(equal(""))

                (left, right) = string.split(from: 10, length: 2)
                expect(left).to(equal("1234567890"))
                expect(right).to(equal(""))
                
                (left, right) = string.split(from: 8, length: 0)
                expect(left).to(equal("12345678"))
                expect(right).to(equal("90"))

            }
        }

    }
}
