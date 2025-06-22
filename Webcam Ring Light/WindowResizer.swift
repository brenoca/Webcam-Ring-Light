import AppKit
import Foundation

class WindowResizer {
    // Store our app's process ID to ensure we never resize our own windows
    private static let ourProcessID = ProcessInfo.processInfo.processIdentifier
    // Error code for accessibility permissions not granted
    private static let kAXErrorPermissionDenied: Int = -25204
    
    // Try to resize windows directly without checking permissions first
    static func resizeWindowsToFitRing(ringDiameter: CGFloat) {
        // Check if we have accessibility permissions with prompt option
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        if !AXIsProcessTrustedWithOptions(options as CFDictionary) {
            showPermissionsAlert()
            return
        }
        
        // Test accessibility with a simple operation first
        if !testAccessibilityPermissions() {
            showPermissionsAlert()
            return
        }
        
        // Try to resize windows using both methods
        let resizedAny = resizeWindowsUsingCGWindowList(ringDiameter: ringDiameter) || 
                         resizeWindowsUsingRunningApplications(ringDiameter: ringDiameter)
        
        // Show appropriate message based on result
        if resizedAny {
            showSuccessAlert()
        } else {
            showNoWindowsAlert()
        }
    }
    
    // Test if we can actually use accessibility APIs by trying a simple operation
    private static func testAccessibilityPermissions() -> Bool {
        // Try to get any frontmost app's windows as a test
        if let frontApp = NSWorkspace.shared.frontmostApplication {
            let appRef = AXUIElementCreateApplication(frontApp.processIdentifier)
            var value: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute as CFString, &value)
            
            // If we get a permission error, we need to prompt
            if result.rawValue == kAXErrorPermissionDenied {
                print("Accessibility test failed with permission error: \(result.rawValue)")
                return false
            }
        }
        return true
    }
    
    // Show permissions alert and guide user to System Settings
    private static func showPermissionsAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permissions Required"
        alert.informativeText = "To resize windows, this app needs Accessibility permissions. Please follow these steps:\n\n1. Click 'Open System Settings' below\n2. In Privacy & Security → Accessibility, find 'Ring Light' in the list\n3. If 'Ring Light' is already checked, uncheck it first\n4. Check the box next to 'Ring Light' again\n5. Completely quit this app (Cmd+Q)\n6. Restart the app\n\nError -25204 indicates that accessibility permissions need to be refreshed."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Fix Permissions")
        alert.addButton(withTitle: "Cancel")
        
        let result = alert.runModal()
        if result == .alertFirstButtonReturn {
            // Open System Settings directly to Accessibility
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
            NSWorkspace.shared.open(url)
        } else if result == .alertSecondButtonReturn {
            // Try to fix permissions
            tryFixPermissions()
        }
    }
    
    // Try to fix permissions by resetting and requesting again
    private static func tryFixPermissions() {
        // First, try a terminal command to reset the accessibility database
        let task = Process()
        task.launchPath = "/usr/bin/tccutil"
        task.arguments = ["reset", "Accessibility", "Light-Co.Ring-Light"]
        
        do {
            try task.run()
            task.waitUntilExit()
            
            // Now prompt for permissions again
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let prompt = NSAlert()
                prompt.messageText = "Permissions Reset"
                prompt.informativeText = "Accessibility permissions have been reset. Please try the 'Resize Windows to Fit' button again."
                prompt.alertStyle = .informational
                prompt.addButton(withTitle: "OK")
                prompt.runModal()
            }
        } catch {
            print("Failed to reset permissions: \(error)")
            
            // Fallback to manual method
            let fallbackAlert = NSAlert()
            fallbackAlert.messageText = "Manual Reset Required"
            fallbackAlert.informativeText = "Please try removing and re-adding the app in System Settings manually."
            fallbackAlert.alertStyle = .warning
            fallbackAlert.addButton(withTitle: "OK")
            fallbackAlert.runModal()
        }
    }
                continue
            }
            
            // Skip our own app and system windows
            if ownerName == Bundle.main.bundleIdentifier ||
               ownerName == "Dock" ||
               ownerName == "Finder" ||
               ownerName == "SystemUIServer" ||
               ownerName.contains("SystemUI") {
                continue
            }
            
            // Try to get the window via Accessibility API
            let appRef = AXUIElementCreateApplication(pid)
            
            // Get all windows for this application
            var windowsRef: CFTypeRef?
            let windowsResult = AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute as CFString, &windowsRef)
            
            guard windowsResult == .success,
                  let windowsArray = windowsRef as? [AXUIElement] else {
                continue
            }
            
            // Find the matching window by iterating through all windows
            var foundWindow: AXUIElement? = nil
            
            for windowRef in windowsArray {
                // Try to get the window ID to match with our CGWindowID
                var windowIDRef: CFTypeRef?
                let idResult = AXUIElementCopyAttributeValue(windowRef, kAXWindowIDAttribute as CFString, &windowIDRef)
                
                if idResult == .success, 
                   let axWindowID = windowIDRef as? NSNumber, 
                   axWindowID.intValue == windowID {
                    foundWindow = windowRef
                    break
                }
            }
            
            // If we couldn't find a matching window, try the first window as fallback
            let windowRef = foundWindow ?? windowsArray.first
            guard let windowRef = windowRef else { continue }
            
            // Get current window position and size
            let currentX = (bounds["X"] as? CGFloat) ?? 0
            let currentY = (bounds["Y"] as? CGFloat) ?? 0
            let currentWidth = (bounds["Width"] as? CGFloat) ?? 0
            let currentHeight = (bounds["Height"] as? CGFloat) ?? 0
            
            // Skip windows that are too small
            if currentWidth < 50 || currentHeight < 50 {
                continue
            }
            
            // Calculate scaling factors
            let widthScale = maxWindowSize.width / currentWidth
            let heightScale = maxWindowSize.height / currentHeight
            let scale = min(widthScale, heightScale, 1) // Don't make windows larger
            
            // Calculate new dimensions
            let newWidth = currentWidth * scale
            let newHeight = currentHeight * scale
            
            // Calculate new position to keep window centered
            let newX = currentX + (currentWidth - newWidth) / 2
            let newY = currentY + (currentHeight - newHeight) / 2
            
            // Set new size
            var sizeValue = CGSize(width: newWidth, height: newHeight)
            if let axSize = AXValueCreate(.cgSize, &sizeValue) {
                let sizeResult = AXUIElementSetAttributeValue(windowRef, kAXSizeAttribute as CFString, axSize)
                if sizeResult == .success {
                    resizedAnyWindow = true
                }
            }
            
            // Set new position
            var positionValue = CGPoint(x: newX, y: newY)
            if let axPosition = AXValueCreate(.cgPoint, &positionValue) {
                AXUIElementSetAttributeValue(windowRef, kAXPositionAttribute as CFString, axPosition)
            }
        }
        
        // If we couldn't resize any windows despite having permissions, show a helpful message
        if !resizedAnyWindow {
            let alert = NSAlert()
            alert.messageText = "Unable to Resize Windows"
            alert.informativeText = "No suitable windows were found to resize. Make sure you have active windows open and try again."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}
