//
//  TransformItemEditController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/28.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa

class TransformItemEditController: NSViewController {

    @IBOutlet weak var tfIndex: NSTextField!
    @IBOutlet weak var tfExtractor: NSTextField!
    @IBOutlet weak var tfReplacement: NSTextField!

    @objc var item: MTransformItem!
    var complete: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.title = "Transform Item Edit"
    }

    @IBAction func okClicked(_ sender: Any) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        commitEditing()
        complete?()
        dismiss(sender)
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }

}
