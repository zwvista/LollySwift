//
//  TransformItemEditController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/07/28.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa

class TransformItemEditController: NSViewController {
    
    @objc var item: MTransformItem!
    var complete: (() -> Void)?

    @IBOutlet weak var tfIndex: NSTextField!
    @IBOutlet weak var tfExtractor: NSTextField!
    @IBOutlet weak var tfReplacement: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    deinit {
        print("DEBUG: \(self.className) deinit")
    }

}
