//
//  SelectableText.swift
//  Bash Commander
//
//  Created by Martin Förster on 05.01.22.
//

import SwiftUI

private struct Selectable  :ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 12.0, *) {
            content.textSelection(.enabled)
        } else {
            content
        }
    }
}

extension View {
    func textSelectable() -> some View {
        modifier(Selectable())
    }
}
