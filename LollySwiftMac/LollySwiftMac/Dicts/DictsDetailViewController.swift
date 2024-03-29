//
//  DictsDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa

class DictsDetailViewController: NSViewController {

    @IBOutlet weak var acLanguages: NSArrayController!
    @IBOutlet weak var acDictTypes: NSArrayController!
    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfLangFrom: NSTextField!
    @IBOutlet weak var pubLangTo: NSPopUpButton!
    @IBOutlet weak var tfSeqNum: NSTextField!
    @IBOutlet weak var pubDictType: NSPopUpButton!
    @IBOutlet weak var tfDictName: NSTextField!
    @IBOutlet weak var tfURL: NSTextField!
    @IBOutlet weak var tfChConv: NSTextField!
    @IBOutlet weak var tfWait: NSTextField!
    @IBOutlet weak var tvAutomation: NSTextView!
    @IBOutlet weak var tvTransform: NSTextView!
    @IBOutlet weak var tvTemplate: NSTextView!
    @IBOutlet weak var tvTemplate2: NSTextView!

    var vm: DictsViewModel!
    var complete: (() -> Void)?
    @objc var item: MDictionary!
    var isAdd: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        isAdd = item.ID == 0
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.title = item.DICTNAME
        tfID.isEnabled = isAdd
        tfLangFrom.stringValue = vm.vmSettings.selectedLang.LANGNAME
        (isAdd ? tfID : tfSeqNum).becomeFirstResponder()
        acLanguages.content = vm.vmSettings.arrLanguages
        acDictTypes.content = vm.vmSettings.arrDictTypes
    }

    @IBAction func editTransform(_ sender: Any) {
        let tranformVC = storyboard!.instantiateController(withIdentifier: "TransformDetailViewController") as! TransformDetailViewController
        tranformVC.vm.item = item
        tranformVC.complete = {  }
        presentAsModalWindow(tranformVC)
    }

    @IBAction func okClicked(_ sender: Any) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        commitEditing()
        Task {
            if isAdd {
                _ = await DictsViewModel.create(item: item)
            } else {
                await DictsViewModel.update(item: item)
            }
            complete?()
            dismiss(sender)
        }
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
