//
//  AccentButton.swift
//  Bash Commander
//
//  Created by Martin Förster on 12.11.20.
//

import SwiftUI

struct MaterialButton: View {
    
    let text: LocalizedStringKey
    let action: () -> Void
    let color: Color
    
    init(text: LocalizedStringKey, color: Color = .accent1, action: @escaping () -> Void) {
        self.text = text
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Group {
            Text(self.text)
                .foregroundColor(Color.white)
                .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity)
        .background(color)
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 4).fill(Color.transparent))
        .onTapGesture(perform: action)
    }
}
