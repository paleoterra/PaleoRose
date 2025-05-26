import Cocoa
import SwiftUI

// MARK: - Window Controller

/// Manages the settings window for the application.
/// Handles the display and state of the settings UI.
public final class SettingsWindowController: NSWindowController {
    // MARK: - Properties
    
    /// Shared instance of the settings window controller.
    public static let shared = SettingsWindowController()
    
    // MARK: - Initialization
    
    public init() {
        let hostingController = NSHostingController(
            rootView: SettingsView()
        )
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 250),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Settings"
        window.contentView = hostingController.view
        
        super.init(window: window)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Window Management
    
    /// Shows the settings window and brings it to the front.
    public func showWindow() {
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
