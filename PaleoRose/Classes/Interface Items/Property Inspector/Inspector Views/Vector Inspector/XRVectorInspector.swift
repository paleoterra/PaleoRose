//
//  XRVectorInspector.swift
//  PaleoRose
//
//  Created by Thomas L. Moore on 5/21/25.
//

import Cocoa

final class XRVectorInspector: NSViewController {

    // MARK: - IBOutlets

    @IBOutlet private var objectController: NSObjectController!

    // MARK: - Properties

    private var currentObject: XRLayerLineArrow?

    // MARK: - Initialization

    init() {
        super.init(nibName: "XRVectorInspector", bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupObjectController()
    }

    // MARK: - Setup

    private func setupObjectController() {
        objectController.objectClass = XRLayerLineArrow.self
    }

    // MARK: - Public Methods

    func displayInfo(for object: AnyObject?) {
        currentObject = object as? XRLayerLineArrow
        objectController.content = currentObject
    }

    // MARK: - IBActions

    @IBAction private func viewRequiresChange(_: Any) {
        currentObject?.generateGraphics()
    }

    // MARK: - Deinitialization

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - XRInspectorProtocol

extension XRVectorInspector: XRInspectorProtocol {
    func displayInfo(for object: AnyObject?) {
        displayInfo(for: object)
    }

    var view: NSView {
        self.view
    }
}
