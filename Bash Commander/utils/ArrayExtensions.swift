//
//  ArrayExtensions.swift
//  Bash Commander
//
//  Created by Martin Förster on 05.01.21.
//

import Foundation

extension Array where Element: Comparable & Hashable  {
    func distinct() -> Array<Element> {
        return Array(Set(self))
    }
}
