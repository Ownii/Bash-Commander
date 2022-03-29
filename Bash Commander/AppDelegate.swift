//
//  AppDelegate.swift
//  Bash Commander
//
//  Created by Martin Förster on 11.11.20.
//

import Cocoa
import SwiftUI
import UserNotifications
import RxSwift
import Swift_IoC_Container

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {

    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    private let navigator = Navigator()
    private let disposeBag = DisposeBag()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        IoCConfigurator().configure(notificationDelegate: self)
    
       setupPopover()
        
        let notifyOnExecutionTermination: NotifyOnExecutionTermination = IoC.shared.resolveOrNil()!
        notifyOnExecutionTermination.invoke().subscribe().disposed(by: disposeBag)
    
    }
    
    private func setupPopover() {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        
        // create popover
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 500)
        popover.behavior = .applicationDefined
        popover.contentViewController = NSHostingController(rootView: contentView.environmentObject(navigator))
        
        self.popover = popover
        
        // create status bar item
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        
        if let button = self.statusBarItem.button {
            button.image = StatusBarIcon.normal.image
            button.action = #selector(togglePopover(_:))
        }
        
        
    }
    
    func updateStatusBarIcon(_ icon: StatusBarIcon) {
        print("trying to change statusBarItem")
        
        if( self.popover.isShown || icon != .normal ) {
            self.statusBarItem?.button?.image = icon.image
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
                NSApp.activate(ignoringOtherApps: true)
                updateStatusBarIcon(.normal)
            }
        }
    }
    
    func applicationWillResignActive(_ notification: Notification) {
        popover.performClose(nil)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if( response.actionIdentifier == "output" ) {
            navigator.open(width: 700, height: 400) { window in
                OutputView(window: window)
            }
        }
        completionHandler()
    }

}


enum StatusBarIcon {
    case normal
    case running
    case succeeded
    case failed
    
    var image: NSImage? {
        switch(self) {
        case .normal:
            return NSImage(named: "StatusBarIcon")
        case .running:
            return NSImage(named: "StatusBarIcon_Running")
        case .succeeded:
            return NSImage(named: "StatusBarIcon_Success")
        case .failed:
            return NSImage(named: "StatusBarIcon_Error")
        }
    }
}
