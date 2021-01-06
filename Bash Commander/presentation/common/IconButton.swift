//
//  IconButton.swift
//  Bash Commander
//
//  Created by Martin Förster on 12.11.20.
//

import SwiftUI

struct IconButton: View {
    
    let name: String
    let action: () -> Void
    let hoverColor: Color
    
    @State private var isHovered = false
    
    init(name: String, hoverColor: Color = .accent1, action: @escaping () -> Void) {
        self.name = name
        self.action = action
        self.hoverColor = hoverColor
    }
    
    var body: some View {
        Image(self.name)
            .renderingMode(.template)
            .colorMultiply(!isHovered ? .icon : hoverColor)
            .onHover { isHovered in
                self.isHovered = isHovered
                if isHovered {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
            .onTapGesture(perform: action)
    }
}
