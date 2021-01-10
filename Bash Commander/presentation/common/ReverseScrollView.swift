//
//  ReverseScrollView.swift
//  Bash Commander
//
//  https://github.com/mremond/SwiftUI-ScrollView-Demo/
//

import SwiftUI

struct ReverseScrollView<Content>: View where Content: View {
    
    var content: () -> Content
    
    var body: some View {
        ScrollView(.vertical) {
            self.content()
                .flip()
        }.flip()
    }
}

extension View {
    public func flip() -> some View {
        return self
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}
