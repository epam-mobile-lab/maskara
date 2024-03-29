//
//  Mask.swift
//  Maskara
//
//  Created by Evgeny Kamyshanov on 07/06/2019.
//  Copyright © 2019 EPAM Systems. All rights reserved.
//

import Foundation

open class Mask {

    public enum State {
        case nop
        case symbol(Character)
        case number
        case letter
        indirect case or(State, State)
        case stop
    }

    public enum EvaluationResult {
        case ok
        case endReached
        case charMismatch(State)
    }

    private let program: [State]
    private var programState: SimpleIterator<State>

    init(with program: [State]) {
        self.program = program
        self.programState = self.program.getSimpleIterator()
    }

    public var maskPlaceholderSymbol: Character = "_"

    final func getCurrentState() -> State {
        return programState.current() ?? .stop
    }

    private final func toNextState() -> State {
        return programState.next() ?? .stop
    }

    final func reset() {
        programState = program.getSimpleIterator()
    }

    final var complete: Bool {
        return programState.finished
    }

    final func onChar(_ char: Character) -> EvaluationResult {
        return evaluate(maskState: toNextState(), with: char)
    }

    final func transformChar(_ char: Character) -> (Character?, EvaluationResult) {
        let result = evaluate(maskState: toNextState(), with: char)
        guard case .ok = result else {
            //The state could be changed internally during [recursive] 'evaluate', so let's get fresh one
            return (render(maskState: getCurrentState()), result)
        }
        if isLetter(state: getCurrentState()) {
            return (Character(char.uppercased()), result)
        }
        return (char, result)
    }

    final func renderNextStep() -> Character? {
        return render(maskState: toNextState())
    }

    // MARK: - implementation

    private final func isLetter(state: State) -> Bool {
        switch state {
        case .letter:
            return true
        case .or(let left, let right):
            return isLetter(state: left) || isLetter(state: right)
        default:
            return false
        }
    }

    private final func evaluate(maskState: State, with char: Character) -> EvaluationResult {
        switch maskState {
        case .nop: return evaluate(maskState: toNextState(), with: char)
        case .number where char.isNumber: return .ok
        case .letter where char.isLetter && char.isASCII : return .ok
        case .symbol(let maskChar) where maskChar == char: return .ok
        case .or(let left, let right):
            let leftResult = evaluate(maskState: left, with: char)
            guard case .ok = leftResult else {
                return evaluate(maskState: right, with: char)
            }
            return leftResult
        case .stop:
            return .endReached
        default:
            return .charMismatch(maskState)
        }
    }

    private final func render(maskState: State) -> Character? {
        switch maskState {
        case .number, .letter:
            return maskPlaceholderSymbol
        case .symbol(let char):
            return char
        case .or(let left, let right):
            switch right {
            case .nop:
                return render(maskState: right)
            default:
                return render(maskState: left)
            }
        default:
            return nil
        }
    }

}
