//
//  MaskaraTests.swift
//  MaskaraTests
//
//  Created by Evgeny Kamyshanov on 06/06/2019.
//  Copyright © 2019 EPAM Systems. All rights reserved.
//

import Foundation
import Nimble
import Quick

@testable import Maskara

class MaskaraTests: QuickSpec {
override func spec() {

    describe("Mask") {
        it("should evaluate sample using optional symbols") {
            let matcher = MaskMatcher(mask: Mask(with: [.or(.symbol("+"), .nop), .number, .number, .number, .or(.symbol("-"), .nop), .number, .number]))
            expect{ try matcher.match(sample: "12345") }.toNot(throwError())
            expect{ try matcher.match(sample: "+12345") }.toNot(throwError())
            expect{ try matcher.match(sample: "123-45") }.toNot(throwError())
            expect{ try matcher.match(sample: "123-") }.toNot(throwError())

            expect{ try matcher.match(sample: "+123-45") }.toNot(throwError())

            let resultComplete = try? matcher.match(sample: "+123-45")
            expect(resultComplete).to(equal(.complete))

            expect{ try matcher.match(sample: "1234") }.toNot(throwError())

            let result = try? matcher.match(sample: "123-")
            expect(result).to(equal(.partial))

            expect{ try matcher.match(sample: "+123a-45") }.to(throwError())
            expect{ try matcher.match(sample: "123--45") }.to(throwError())
            expect{ try matcher.match(sample: "---") }.to(throwError())
        }
    }

    describe("Russian mask") {
        it("should evaluate sample using optional and conditional symbols") {
            let program: [Mask.State] =
                [.or(.symbol("+"), .nop), .or(.symbol("7"), .symbol("8")), .number, .number, .number, .or(.symbol("-"), .nop), .number, .number, .or(.symbol("-"), .nop), .number, .number]

            let matcher = MaskMatcher(mask: Mask(with: program))

            expect{ try matcher.match(sample: "+7123-45-67") }.toNot(throwError())
        }
    }

    describe("Text mask") {
        it("should compile textual mask") {
            expect{ _ = try TextualMask(with: "+?DDD-?DD") }.toNot(throwError())
        }

        it("should evaluate sample") {
            let matcher = MaskMatcher(mask: try! TextualMask(with: "+?DDD-?DD"))

            expect{ try matcher.match(sample: "12345") }.toNot(throwError())
            expect{ try matcher.match(sample: "+12345") }.toNot(throwError())
            expect{ try matcher.match(sample: "123-45") }.toNot(throwError())
            expect{ try matcher.match(sample: "123-") }.toNot(throwError())
        }
    }

    describe("Advanced text mask") {
        it("should compile complex mask") {
            let mask = "+?7|8-| ?DDD-| ?DD-| ?DD"
            expect{ _ = try TextualMask(with: mask) }.toNot(throwError())

            let matcher = MaskMatcher(mask: try! TextualMask(with: mask))

            expect{ try matcher.match(sample: "+7123-45-67") }.toNot(throwError())
            expect{ try matcher.match(sample: "+7123 45 67") }.toNot(throwError())
            expect{ try matcher.match(sample: "81234567") }.toNot(throwError())
        }

        it("should not compile invalid mask patterns") {
            expect{ _ = try TextualMask(with: "+??") }.to(throwError())
            expect{ _ = try TextualMask(with: "+||7") }.to(throwError())
            expect{ _ = try TextualMask(with: "7|") }.to(throwError())
            expect{ _ = try TextualMask(with: "|7") }.to(throwError())
            expect{ _ = try TextualMask(with: "?|7") }.to(throwError())
            expect{ _ = try TextualMask(with: "1|?") }.to(throwError())
        }

        it("should compile complex mask pattern expressions") {
            let extMask = "+?|8|7"

            expect{ _ = try TextualMask(with: extMask) }.toNot(throwError())

            let advMatcher = MaskMatcher(mask: try! TextualMask(with: extMask))
            expect{ try advMatcher.match(sample: "+") }.toNot(throwError())
            expect{ try advMatcher.match(sample: "8") }.toNot(throwError())
            expect{ try advMatcher.match(sample: "7") }.toNot(throwError())
            expect{ try advMatcher.match(sample: "") }.toNot(throwError())
        }
    }

    describe("Optimistic parsing") {
        it("should evaluate partially matching samples") {
            let mask = "+7|8(DDD)DDD-DD-DD"
            expect{ _ = try TextualMask(with: mask) }.toNot(throwError())

            let matcher = MaskMatcher(mask: try! TextualMask(with: mask), options: [.optimisticMatch])

            expect{ try matcher.match(sample: "9211234567") }.toNot(throwError())
            expect{ try matcher.match(sample: "89211234567") }.toNot(throwError())
            expect{ try matcher.match(sample: "77211234567") }.toNot(throwError())
            expect{ try matcher.match(sample: "(921)1234567") }.toNot(throwError())
            expect{ try matcher.match(sample: "921)1234567") }.toNot(throwError())
            expect{ try matcher.match(sample: "8921)1234567") }.toNot(throwError())

            let result = try? matcher.match(sample: "7211234567")
            expect(result).to(equal(.partial))
        }
    }

    describe("Mask extension") {
        it("should allow extended symbol set in mask pattern") {
            let allowedSymbolTokens: [Character] = ["$", ".", " ", "-", "+"]
            expect{ try? MaskParser(pattern: "-|+?$DDD ?DDD.DD?", allowedSymbolTokens: allowedSymbolTokens) }.toNot(throwError())
            let moneyMaskParser = try! MaskParser(pattern: "-|+?$DDD ?DDD.|D?D?D?", allowedSymbolTokens: allowedSymbolTokens)
            let matcher = MaskMatcher(mask: Mask(with: moneyMaskParser.program), options: [.optimisticMatch])

            expect{ try matcher.match(sample: "$123 123.11") }.toNot(throwError())
            expect{ try matcher.match(sample: "$123123.1") }.toNot(throwError())
            expect{ try matcher.match(sample: "$123123") }.toNot(throwError())
            expect{ try matcher.match(sample: "-$123123") }.toNot(throwError())
            expect{ try matcher.match(sample: "+$123123") }.toNot(throwError())

            expect{ try matcher.match(sample: "$123(123).11") }.to(throwError())
        }
    }

    describe("Letters") {
        it("should be able to handle letters in mask") {
            let mask = "+7|8(DDD)DDD-?D|XD|X-?D|XD|X"
            expect{ _ = try TextualMask(with: mask) }.toNot(throwError())

            let matcher = MaskMatcher(mask: try! TextualMask(with: mask), options: [.optimisticMatch])

            expect{ try matcher.match(sample: "9211234567") }.toNot(throwError())
            expect{ try matcher.match(sample: "89211234567") }.toNot(throwError())
            expect{ try matcher.match(sample: "+77211234567") }.toNot(throwError())

            expect{ try matcher.match(sample: "921123MYAP") }.toNot(throwError())
            expect{ try matcher.match(sample: "892112345AP") }.toNot(throwError())
            expect{ try matcher.match(sample: "+7721123MY67") }.toNot(throwError())

            expect{ try matcher.match(sample: "+772112MYAPP") }.to(throwError())

            let result = try? matcher.match(sample: "721123M")
            expect(result).to(equal(.partial))
        }
    }

    describe("Transform") {
        context("should modify sample by mask rules") {
            let mask = "+?7|8(DDD)DDD-DD-DD"
            it("with optimistic match") {
                let matcher = MaskMatcher(mask: try! TextualMask(with: mask), options: [.optimisticMatch])

                expect(matcher.renderMask(resetMask: false)).to(equal("7(___)___-__-__"))

                var string = try! matcher.transform(sample: "9211")

                expect(string).to(equal("7(921)1"))
                string += matcher.renderMask(resetMask: false)
                expect(string).to(equal("7(921)1__-__-__"))

                string = try! matcher.transform(sample: "")
                expect(string).to(equal(""))
            }

            it("without optimistic match") {
                let parser2 = MaskMatcher(mask: try! TextualMask(with: mask))
                expect{ try parser2.transform(sample: "9211") }.to(throwError())
                expect{ try parser2.transform(sample: "+7(921)1") }.toNot(throwError())
                expect{ try parser2.transform(sample: "8(921)1") }.toNot(throwError())
            }
        }
    }

    describe("Extract") {
        it("should be able to filter meanungful data from sample by mask") {
            let mask = "+?7|8(DDD)DDD-| ?DD-| ?DD"
            let matcher = MaskMatcher(mask: try! TextualMask(with: mask), options: [.optimisticMatch])

            var extract = try? matcher.extract(from: "+7(123)456-78-90")
            expect(extract).to(beExtractComplete("1234567890"))
            extract = try? matcher.extract(from: "7(123)456 7890")
            expect(extract).to(beExtractComplete("1234567890"))
            extract = try? matcher.extract(from: "7(123)456")
            expect(extract).to(beExtractPartial("123456"))

            expect{ try matcher.extract(from: "456-78-90") }.to(throwError())
        }
    }

}
}

// MARK: - Customization

private func beExtractComplete(_ test: String = "") -> Predicate<MaskMatcher.ExtractResult> {
    return Predicate.define("be <complete(\(test))>") { expression, message in
        if let actual = try expression.evaluate(), case .complete(let extract) = actual, test == extract {
            return PredicateResult(status: .matches, message: message)
        }
        return PredicateResult(status: .fail, message: message)
    }
}

private func beExtractPartial(_ test: String = "") -> Predicate<MaskMatcher.ExtractResult> {
    return Predicate.define("be <partial(\(test))>") { expression, message in
        if let actual = try expression.evaluate(), case .partial(let extract) = actual, test == extract {
            return PredicateResult(status: .matches, message: message)
        }
        return PredicateResult(status: .fail, message: message)
    }
}


