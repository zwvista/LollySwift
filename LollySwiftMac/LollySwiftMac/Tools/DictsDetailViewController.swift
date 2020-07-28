//
//  DictsDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import NSObject_Rx

class DictsDetailViewController: NSViewController {

    var vm: DictsViewModel!
    var complete: (() -> Void)?
    @objc var item: MDictionary!
    var isAdd: Bool!

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

    override func viewDidLoad() {
        super.viewDidLoad()
        isAdd = item.ID == 0
    }
    
    override func viewDidAppear() {
        view.window?.title = item.DICTNAME
        tfID.isEnabled = isAdd
        tfLangFrom.stringValue = vm.vmSettings.selectedLang.LANGNAME
        (isAdd ? tfID : tfSeqNum).becomeFirstResponder()
        acLanguages.content = vm.vmSettings.arrLanguages
        acDictTypes.content = vm.vmSettings.arrDictTypes
    }

    @IBAction func editTransform(_ sender: Any) {
        let tranformVC = self.storyboard!.instantiateController(withIdentifier: "TransformEditViewController") as! TransformEditViewController
        tranformVC.complete = {  }
        self.presentAsModalWindow(tranformVC)
    }
    
    @IBAction func okClicked(_ sender: Any) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        if isAdd {
            DictsViewModel.create(item: item).subscribe {
                self.complete?()
            } ~ rx.disposeBag
        } else {
            DictsViewModel.update(item: item).subscribe {
                self.complete?()
            } ~ rx.disposeBag
        }
        dismiss(self)
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
