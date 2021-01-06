//
//  AppDelegate.swift
//  Bash Commander
//
//  Created by Martin Förster on 11.11.20.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        IoCConfigurator().configure()
    
       setupPopover()
    
    }
    
    private func setupPopover() {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        
        // create popover
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 500)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView.environmentObject(Navigator()))
        
        self.popover = popover
        
        // create status bar item
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        
        if let button = self.statusBarItem.button {
            button.image = NSImage(named: "StatusBarIcon")
            button.action = #selector(togglePopover(_:))
        }
        
    }
        
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem.button {
            if( self.popover.isShown ) {
                self.popover.performClose(sender)
            }
            else {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                self.popover.contentViewController?.view.window?.becomeKey()
            }
        }
    }

}
