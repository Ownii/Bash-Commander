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
    let size: CGFloat
    let badge: Bool
    
    @State private var isHovered = false
    
    init(name: String, hoverColor: Color = .accent1, size: CGFloat = 18, badge: Bool = false, action: @escaping () -> Void) {
        self.name = name
        self.action = action
        self.hoverColor = hoverColor
        self.size = size
        self.badge = badge
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(self.name)
                .resizable()
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
                .frame(width: size, height: size)
            if( badge ) {
                Circle()
                    .fill(Color.error)
                    .frame(width: 8, height: 8)
            }
        }
    }
}
