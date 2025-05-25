// XRAppendDialogController.swift
// MIT License
// Copyright (c) 2004 to present Thomas L. Moore.
import Cocoa

@objc class XRAppendDialogController: NSWindowController {
    @IBOutlet var popupButton: NSPopUpButton?
    var titlesArray: [String] = []

    @IBAction func append(_: Any?) {}
    @IBAction func cancel(_: Any?) {}
    @IBAction func new(_: Any?) {}
    @objc func popup() -> NSPopUpButton? { popupButton }
    @objc func titleOfSelectedSet() -> String? { popupButton?.titleOfSelectedItem }
    @objc func setDataSetArray(_ dataSetTitles: [String]) { titlesArray = dataSetTitles }
}
