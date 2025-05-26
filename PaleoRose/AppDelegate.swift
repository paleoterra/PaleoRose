//
// AppDelegate.swift
// PaleoRose
//
// MIT License
//
// Copyright (c) 2024 to present Thomas L. Moore.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - Properties

    private var aboutWindow: NSWindow?
    private var settingsWindowController: SettingsWindowController?

    private var applicationName: String {
        Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String ?? ""
    }

    // MARK: - Menu Actions
    // swiftlint:disable:next prohibited_interface_builder
    @IBAction private func showSettings(_ sender: Any?) {
        showSettingsWindow(sender)
    }

    // swiftlint:disable:next prohibited_interface_builder
    @IBAction private func showAbout(_ sender: Any?) {
        showAboutWindow(sender)
    }

    // MARK: - Application Lifecycle

    func applicationDidFinishLaunching(_: Notification) {
        NSColorPanel.shared.showsAlpha = true
    }

    // MARK: - Actions

    private func showSettingsWindow(_ sender: Any?) {
        settingsWindowController = SettingsWindowController()
        settingsWindowController?.showWindow(sender)
    }

    private func showAboutWindow(_: Any?) {
        let width: CGFloat = 400
        let height: CGFloat = 250
        if aboutWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: width, height: height),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )

            window.center()
            window.title = "About \(applicationName)"
            window.contentView = NSHostingView(rootView: AboutView())
            aboutWindow = window
        }
        aboutWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
