//
//  MenuBarView.swift
//  Webcam Ring Light
//
//  Created by Breno Araujo on 29.10.2024.
//

// Version2 Old UI bar with slider

import SwiftUI

//struct MenuBarView: View {
//    @ObservedObject var windowManager: WindowManager
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Ring Controls")
//                .font(.headline)
//                .padding()
//            
//            VStack(alignment: .leading) {
//                Text("Size: \(Int(windowManager.radiusPercentage))%")
//                Slider(
//                    value: $windowManager.radiusPercentage,
//                    in: 50...150,
//                    step: 10
//                )
//            }
//            .padding()
//            
//            VStack(alignment: .leading) {
//                Text("Width: \(String(format: "%.1f", windowManager.borderPercentage))%")
//                Slider(
//                    value: $windowManager.borderPercentage,
//                    in: 5...50,
//                    step: 5
//                )
//            }
//            .padding()
//            
//            Toggle("Show Ring", isOn: $windowManager.isVisible)
//                .padding()
//            
//            Button("Quit") {
//                NSApplication.shared.terminate(nil)
//            }.padding()
//        }
//    }
//}

struct MenuBarView: View {
    @ObservedObject var windowManager: WindowManager
    @State private var showingAccessibilityAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ring Controls")
                .font(.headline)
                .padding(.bottom, 4)
            
            VStack(alignment: .leading) {
                Text("Radius: \(Int(windowManager.radiusPercentage))%")
                Slider(
                    value: $windowManager.radiusPercentage,
                    in: 50...150,
                    step: 10
                )
            }
            .padding(.vertical, 4)
            
            VStack(alignment: .leading) {
                Text("Border: \(String(format: "%.1f", windowManager.borderPercentage))%")
                Slider(
                    value: $windowManager.borderPercentage,
                    in: 5...50,
                    step: 5
                )
            }
            .padding(.vertical, 4)
            
            Toggle("Show Ring", isOn: $windowManager.isVisible)
                .padding(.vertical, 4)
            
            Divider()
                .padding(.vertical, 4)
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(.vertical, 8) // Added vertical padding
        .frame(width: 280) // Set a consistent width
    }
}

// First Working version

//struct MenuBarView: View {
//    @ObservedObject var windowManager: WindowManager
//    
//    var body: some View {
//        Group {
//            Text("Radius: \(Int(windowManager.radiusPercentage))%")
//            
//            Button("Increase Radius (↑)") {
//                windowManager.radiusPercentage = min(150, windowManager.radiusPercentage + 10)
//            }
//            .keyboardShortcut(.upArrow, modifiers: [])
//            
//            Button("Decrease Radius (↓)") {
//                windowManager.radiusPercentage = max(50, windowManager.radiusPercentage - 10)
//            }
//            .keyboardShortcut(.downArrow, modifiers: [])
//            
//            Divider()
//            
//            Text("Border: \(Int(windowManager.borderPercentage))px")
//            
//            Button("Increase Border (+)") {
//                windowManager.borderPercentage = min(50, windowManager.borderPercentage + 5)
//            }
//            .keyboardShortcut("+", modifiers: [])
//            
//            Button("Decrease Border (-)") {
//                windowManager.borderPercentage = max(5, windowManager.borderPercentage - 5)
//            }
//            .keyboardShortcut("-", modifiers: [])
//            
//            Divider()
//            
//            Button(windowManager.isVisible ? "Hide Ring" : "Show Ring") {
//                windowManager.isVisible.toggle()
//            }
//            .keyboardShortcut("h", modifiers: [.command])
//            
//            Divider()
//            
//            Button("Quit") {
//                NSApplication.shared.terminate(nil)
//            }
//            .keyboardShortcut("q", modifiers: [.command])
//        }
//    }
//}
