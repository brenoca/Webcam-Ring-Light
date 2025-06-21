//
//  Webcam_Ring_LightApp.swift
//  Webcam Ring Light
//
//  Created by Breno Araujo on 29.10.2024.
//
    
import SwiftUI

// Version2 Old UI bar with slider

@main
struct LightRingApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings { }  // Empty settings scene
    }
}

// First Working version

//@main
//struct LightRingApp: App {
//    @StateObject private var windowManager = WindowManager()
//    
//    var body: some Scene {
//        MenuBarExtra("Light Ring", systemImage: "circle") {
//            MenuBarView(windowManager: windowManager)
//        }
//    }
//}
