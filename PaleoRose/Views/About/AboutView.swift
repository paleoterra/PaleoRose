//
//  AboutView.swift
//  PaleoRose
//
//  MIT License
//
//  Copyright (c) 2004-2024 Thomas L. Moore.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import SwiftUI

struct AboutView: View {
    private let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
    private let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    private let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
    private let copyright = "Copyright © 2004-\(Calendar.current.component(.year, from: Date())) Thomas L. Moore"

    var body: some View {
        VStack(spacing: 20) {
            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                .resizable()
                .frame(width: 64, height: 64)
                .padding(.top, 20)
                .accessibilityHidden(true)

            Text(appName)
                .font(.title)
                .fontWeight(.bold)

            Text("Version \(version) (\(build))")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("A rose diagram application")
                .font(.body)
                .padding(.bottom, 10)

            Text(copyright)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
        }
        .frame(width: 400, height: 300)
        .onAppear {
            // Center the window when it appears
            if let window = NSApp.keyWindow {
                window.center()
            }
        }
    }
}

// MARK: - Previews

#Preview {
    AboutView()
        .frame(width: 400, height: 300)
}
