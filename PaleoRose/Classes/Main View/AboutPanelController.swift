// AboutPanelController.swift
//
// MIT License
//
// Copyright (c) 2005 to present Thomas L. Moore.
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

@objc class AboutPanelController: NSObject {
    @IBOutlet private weak var buildNumber: NSTextField!
    @IBOutlet private weak var panel: NSPanel!
    
    @IBAction func showAboutPanel(_ sender: Any?) {
        let screenRect = NSScreen.main?.frame ?? .zero
        var panelRect = panel.frame
        
        panelRect.origin.x = (screenRect.width - panelRect.width) / 2.0
        panelRect.origin.y = (screenRect.height - panelRect.height) / 2.0
        
        panel.setFrame(panelRect, display: true)
        panel.makeKey()
        panel.orderFront(sender)
    }
}
