// FStatisticController.swift
// MIT License
// Copyright (c) 2004 to present Thomas L. Moore.
import Cocoa

@objc class FStatisticController: NSWindowController {
    @IBOutlet weak var layerNameField1: AnyObject?
    @IBOutlet weak var layerNameField2: AnyObject?
    @IBOutlet weak var cancelButton: AnyObject?
    @IBOutlet weak var executeButton: AnyObject?
    @IBOutlet weak var biDirectionalSwitch: AnyObject?
    var layerArray: [Any] = []
    
    @IBAction func calculateSheet(_ sender: Any?) {}
    @IBAction func cancelSheet(_ sender: Any?) {}
    @objc func setLayerNames(_ nameList: [String]) {}
    @objc func selectedItems() -> [Any] { return [] }
    @objc func isBiDirectional() -> Bool { return false }
    @objc func populateLayers() {}
}
