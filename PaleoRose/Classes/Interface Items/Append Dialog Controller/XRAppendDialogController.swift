// XRAppendDialogController.swift
// MIT License
// Copyright (c) 2004 to present Thomas L. Moore.
import Cocoa

@objc class XRAppendDialogController: NSWindowController {
    @IBOutlet weak var popupButton: NSPopUpButton?
    var titlesArray: [String] = []
    
    @IBAction func append(_ sender: Any?) {}
    @IBAction func cancel(_ sender: Any?) {}
    @IBAction func new(_ sender: Any?) {}
    @objc func popup() -> NSPopUpButton? { return popupButton }
    @objc func titleOfSelectedSet() -> String? { return popupButton?.titleOfSelectedItem }
    @objc func setDataSetArray(_ dataSetTitles: [String]) { titlesArray = dataSetTitles }
}
