//
//  MaskaraTestUtil.swift
//  MaskaraTests
//
//  Created by Evgeny Kamyshanov on 14/06/2019.
//  Copyright © 2019 EPAM Systems. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import Maskara

// MARK: - Predicates customization

func beExtractComplete(_ test: String = "") -> Predicate<ExtractResult> {
    return Predicate.define("be <complete(\(test))>") { expression, message in
        if let actual = try expression.evaluate(), case .complete(let extract) = actual, test == extract {
            return PredicateResult(status: .matches, message: message)
        }
        return PredicateResult(status: .fail, message: message)
    }
}

func beExtractPartial(_ test: String = "") -> Predicate<ExtractResult> {
    return Predicate.define("be <partial(\(test))>") { expression, message in
        if let actual = try expression.evaluate(), case .partial(let extract) = actual, test == extract {
            return PredicateResult(status: .matches, message: message)
        }
        return PredicateResult(status: .fail, message: message)
    }
}
