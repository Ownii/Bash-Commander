//
//  AccentButton.swift
//  Bash Commander
//
//  Created by Martin Förster on 12.11.20.
//

import SwiftUI

struct AccentButton: View {
    
    let text: LocalizedStringKey
    let action: () -> Void
    
    init(text: LocalizedStringKey, action: @escaping () -> Void) {
        self.text = text
        self.action = action
    }
    
    var body: some View {
        Group {
            Text(self.text)
                .foregroundColor(Color.white)
                .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity)
        .background(Color.accent1)
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 4).fill(Color.transparent))
        .onTapGesture(perform: action)
    }
}
