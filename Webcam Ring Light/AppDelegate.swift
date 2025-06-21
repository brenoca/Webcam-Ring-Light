//
//  AppDelegate.swift
//  Ring Light
//
//  Created by Breno Araujo on 30.10.2024.
//

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var windowManager: WindowManager!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon - do this first
        NSApp.setActivationPolicy(.accessory)
        
        // Immediately hide any existing windows
        NSApplication.shared.windows.forEach { window in
            window.close()
        }
        
        // Create window manager
        windowManager = WindowManager()
        
        // Create popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 280)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: MenuBarView(windowManager: windowManager)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        )
        
        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let statusButton = statusItem.button {
            statusButton.image = NSImage(systemSymbolName: "circle", accessibilityDescription: "Light Ring")
            statusButton.action = #selector(togglePopover)
            statusButton.target = self
        }
    }
    
    @objc func togglePopover() {
        if let statusButton = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: statusButton.bounds, of: statusButton, preferredEdge: .minY)
                // Make sure the popover's window is key window
                NSApp.activate(ignoringOtherApps: true)
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }
}

// Version2 Old UI bar with slider

//import SwiftUI
//import AppKit
//
//class AppDelegate: NSObject, NSApplicationDelegate {
//    var statusItem: NSStatusItem!
//    var popover: NSPopover!
//    var windowManager: WindowManager!
//    
//    func applicationDidFinishLaunching(_ notification: Notification) {
//        // Create window manager
//        windowManager = WindowManager()
//        
//        // Create popover
//        popover = NSPopover()
//        popover.contentSize = NSSize(width: 300, height: 200)
//        popover.behavior = .transient
//        popover.contentViewController = NSHostingController(
//            rootView: MenuBarView(windowManager: windowManager)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .padding()
//        )
//        
//        // Create status item
//        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
//        
//        if let statusButton = statusItem.button {
//            statusButton.image = NSImage(systemSymbolName: "circle", accessibilityDescription: "Light Ring")
//            statusButton.action = #selector(togglePopover)
//            statusButton.target = self
//        }
//        
//        // Hide dock icon
//        NSApp.setActivationPolicy(.accessory)
//    }
//    
//    @objc func togglePopover() {
//        if let statusButton = statusItem.button {
//            if popover.isShown {
//                popover.performClose(nil)
//            } else {
//                popover.show(relativeTo: statusButton.bounds, of: statusButton, preferredEdge: .minY)
//                popover.contentViewController?.view.window?.makeKey()
//            }
//        }
//    }
//}
