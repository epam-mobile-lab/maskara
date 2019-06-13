//
//  TextualMask.swift
//  Maskara
//
//  Created by Evgeny Kamyshanov on 07/06/2019.
//  Copyright © 2019 EPAM Systems. All rights reserved.
//

import Foundation

open class TextualMask: Mask {

    public let pattern: String

    init(with pattern: String) throws {
        self.pattern = pattern
        super.init(with: try MaskParser(pattern: pattern).program)
    }
}

public final class MaskParser {

    enum Token {
        case charToken(Character)
        case numberToken
        case letterToken
        case orOperationToken
        case optionalOperationToken
    }

    enum Node {
        case numberNode
        case letterNode
        case symbolNode(Character)
        indirect case optionalNode(Node)
        indirect case orOperation(Node, Node)
    }

    enum MaskParserError: Error {
        case parsingError(String)
        case compilationError(String)
        case illegalAllowedSymbols
    }

    enum Option {
        case numbersAsCharacters
    }

    private(set) var program = [Mask.State]()

    public static let defaultSymbolTokens: [Character] = ["+", "-", " ", "(", ")"]
    public static let numberToken: Character = "D"
    public static let letterToken: Character = "X"
    public static let optionalToken: Character = "?"
    public static let orOperationToken: Character = "|"

    private static let auxiliarySymbols = [MaskParser.numberToken, MaskParser.letterToken, MaskParser.optionalToken, MaskParser.orOperationToken]

    private let allowedSymbolTokens: [Character]

    private let numbersAsCharacters: Bool

    init(pattern: String, options: [Option] = [.numbersAsCharacters], allowedSymbolTokens: [Character]? = nil) throws {
        if let tokens = allowedSymbolTokens {
            if tokens.reduce(false, { $0 && MaskParser.auxiliarySymbols.contains($1) }) {
                throw MaskParserError.illegalAllowedSymbols
            }
            self.allowedSymbolTokens = tokens
        } else {
            self.allowedSymbolTokens = MaskParser.defaultSymbolTokens
        }
        self.numbersAsCharacters = options.contains(.numbersAsCharacters)
        self.program = try compileMask(pattern: pattern)
    }

    // MARK: - implementation

    private final func compileMask(pattern: String) throws -> [Mask.State] {
        let tokens = try pattern.map { return try parseToken($0) }
        let nodes = try compile(tokens: tokens)
        return generate(from: nodes)
    }

    private final func generate(from node: Node) -> Mask.State {
        switch node {
        case .numberNode:
            return .number
        case .letterNode:
            return .letter
        case .symbolNode(let symbol):
            return .symbol(symbol)
        case .optionalNode(let node):
            return .or(generate(from: node), .nop)
        case .orOperation(let leftNode, let rightNode):
            return .or(generate(from: leftNode), generate(from: rightNode))
        }
    }

    private final func generate(from nodes: [Node]) -> [Mask.State] {
        return nodes.map { generate(from: $0) }
    }

    private final func compile(tokens: [Token]) throws -> [Node] {
        let tokenIterator = tokens.getSimpleIterator()

        var stack = [Node]()
        var nodes = [Node]()

        while let token = tokenIterator.next() {
            if let node = try evaluate(stack: &stack, token: token, iterator: tokenIterator) {
                nodes.append(node)
            }
        }

        if let lastNode = stack.popLast() {
            nodes.append(lastNode)
        }

        return nodes
    }

    private final func evaluate(stack: inout [Node], token: Token, iterator: SimpleIterator<Token>) throws -> Node? {
        switch token {
        case .charToken(let symbol):
            let lastTok = stack.popLast()
            stack.append(.symbolNode(symbol))
            return lastTok
        case .numberToken:
            let lastTok = stack.popLast()
            stack.append(.numberNode)
            return lastTok
        case .letterToken:
            let lastTok = stack.popLast()
            stack.append(.letterNode)
            return lastTok
        case .orOperationToken:
            guard let lastNode = stack.popLast() else {
                throw MaskParserError.compilationError("Operator '|' should only be preceded by any valid expression")
            }
            guard let tok = iterator.next() else {
                throw MaskParserError.compilationError("Operator '|' needs a right operand")
            }
            _ = try evaluate(stack: &stack, token: tok, iterator: iterator)
            if let rightNode = stack.popLast() {
                stack.append(.orOperation(lastNode, rightNode))
            }
        case .optionalOperationToken:
            guard let lastNode = stack.popLast() else {
                throw MaskParserError.compilationError("Operator '?' should be preceded by any valid expression")
            }
            if case .optionalNode(_) = lastNode {
                throw MaskParserError.compilationError("Operator '?' cannot be preceded by an optional expression")
            }
            stack.append(.optionalNode(lastNode))
        }
        return nil
    }

    private final func parseToken(_ char: Character) throws -> Token {
        switch char {
        case MaskParser.numberToken: return .numberToken
        case MaskParser.letterToken: return .letterToken
        case MaskParser.orOperationToken: return .orOperationToken
        case MaskParser.optionalToken: return .optionalOperationToken
        case _ where allowedSymbolTokens.contains(char): return .charToken(char)
        default:
            if char.isNumber && numbersAsCharacters { return .charToken(char) }
            throw MaskParserError.parsingError("Unexpected mask symbol: '\(char)'")
        }
    }
}
