import AppKit

class WindowResizer {
    // Check if we have accessibility permissions
    static func hasAccessibilityPermissions() -> Bool {
        return AXIsProcessTrusted()
    }
    
    // Request accessibility permissions with a prompt
    static func requestAccessibilityPermissions() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    // Show permissions alert and guide user to System Settings
    static func showPermissionsAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permissions Required"
        alert.informativeText = "To resize windows, this app needs Accessibility permissions. Please grant them in System Settings → Privacy & Security → Accessibility, then try again."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            // Use the modern URL scheme for macOS
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    static func resizeWindowsToFitRing(ringDiameter: CGFloat) {
        // First check if we have permissions
        if !hasAccessibilityPermissions() {
            showPermissionsAlert()
            return
        }
        
        // Get screen and maximum window size
        guard let screen = NSScreen.main else { return }
        let maxWindowSize = CGSize(width: ringDiameter * 0.9, height: ringDiameter * 0.9) // 90% of ring size
        
        // Track if we successfully resized any windows
        var resizedAnyWindow = false
        
        // Get all visible windows
        let options = CGWindowListOption(arrayLiteral: .optionOnScreenOnly, .excludeDesktopElements)
        let windowList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] ?? []
        
        for windowDict in windowList {
            // Extract window information
            guard let bounds = windowDict[kCGWindowBounds as String] as? [String: Any],
                  let ownerName = windowDict[kCGWindowOwnerName as String] as? String,
                  let windowID = windowDict[kCGWindowNumber as String] as? Int,
                  let pid = windowDict[kCGWindowOwnerPID as String] as? pid_t else {
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
