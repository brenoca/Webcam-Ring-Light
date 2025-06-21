//
//  AppDelegate.swift
//  Ring Light
//
//  Created by Breno Araujo on 30.10.2024.
//

// Version2 Old UI bar with slider

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var windowManager: WindowManager!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create window manager
        windowManager = WindowManager()
        
        // Create popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 200)
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
        
        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)
    }
    
    @objc func togglePopover() {
        if let statusButton = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: statusButton.bounds, of: statusButton, preferredEdge: .minY)
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }
}
