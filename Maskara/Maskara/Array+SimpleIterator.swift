//
//  Array+SimpleIterator.swift
//  Maskara
//
//  Created by Evgeny Kamyshanov on 07/06/2019.
//  Copyright © 2019 EPAM Systems. All rights reserved.
//

import Foundation

public class SimpleIterator<Element> {

    private let array: ArraySlice<Element>
    private var index: Int

    init(_ array: ArraySlice<Element>) {
        self.array = array
        self.index = -1
    }

    public final func next() -> Element? {
        index += 1
        return current()
    }

    public final func current() -> Element? {
        guard index >= 0 && index < array.count else {
            return nil
        }
        return array[index]
    }

    public final var finished: Bool {
        return index >= array.count - 1
    }

    private init(_ array: ArraySlice<Element>, _ index: Int) {
        self.array = array
        self.index = index
    }

    public final func copy() -> SimpleIterator<Element> {
        return SimpleIterator(array, index)
    }
}

extension Array {
    func getSimpleIterator() -> SimpleIterator<Element> {
        return SimpleIterator(self[...])
    }
}
