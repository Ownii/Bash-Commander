//
//  Navigator.swift
//  Bash Commander
//
//  Created by Martin Förster on 12.11.20.
//

import Foundation
import SwiftUI
 
class Navigator: ObservableObject {
    
    func open<SomeView: View>(width: Int = 300, height: Int = 300, resizable: Bool = false, @ViewBuilder builder: @escaping (NSWindow) -> SomeView) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.contentView = NSHostingView(rootView: builder(window))
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
}

struct Window<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
    }
}
