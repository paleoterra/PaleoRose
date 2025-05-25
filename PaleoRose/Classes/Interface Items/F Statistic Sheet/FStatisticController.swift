// FStatisticController.swift
// MIT License
// Copyright (c) 2004 to present Thomas L. Moore.
import Cocoa

@objc class FStatisticController: NSWindowController {
    @IBOutlet var layerNameField1: AnyObject?
    @IBOutlet var layerNameField2: AnyObject?
    @IBOutlet var cancelButton: AnyObject?
    @IBOutlet var executeButton: AnyObject?
    @IBOutlet var biDirectionalSwitch: AnyObject?
    var layerArray: [Any] = []

    @IBAction func calculateSheet(_: Any?) {}
    @IBAction func cancelSheet(_: Any?) {}
    @objc func setLayerNames(_: [String]) {}
    @objc func selectedItems() -> [Any] { [] }
    @objc func isBiDirectional() -> Bool { false }
    @objc func populateLayers() {}
}
