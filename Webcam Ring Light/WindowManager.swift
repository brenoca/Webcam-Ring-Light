//
//  WindowManager.swift
//  Webcam Ring Light
//
//  Created by Breno Araujo on 29.10.2024.
//

import SwiftUI
import AppKit

class OverlayWindow: NSWindow {
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
}

class WindowManager: ObservableObject {
    @Published var radiusPercentage: Double = 100 // Start at 100%
    @Published var borderPercentage: Double = 10 // Start at 10% of screen size
    @Published var isVisible: Bool = true {
        didSet {
            if isVisible {
                createWindowIfNeeded()
            } else {
                closeWindow()
            }
        }
    }
    
    private var window: NSWindow?
    private var screenObserver: Any?
    
    init() {
        createWindowIfNeeded()
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                self?.updateWindow()
            }
    }
    
    deinit {
        if let observer = screenObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func closeWindow() {
        window?.orderOut(nil)
        window = nil
    }
    
    private func updateWindow() {
        guard let screen = NSScreen.main else { return }
        window?.setFrame(screen.frame, display: true)
    }
    
    func createWindowIfNeeded() {
        guard window == nil else { return }
        
        guard let screen = NSScreen.main else { return }
        
        // Use our custom window class instead of NSWindow
        let window = OverlayWindow(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        window.level = .floating
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        
        let hostingView = NSHostingView(
            rootView: ObservableRingView(windowManager: self)
        )
        
        window.contentView = hostingView
        window.orderFront(nil)  // Changed from makeKeyAndOrderFront to orderFront
        self.window = window
    }
}
