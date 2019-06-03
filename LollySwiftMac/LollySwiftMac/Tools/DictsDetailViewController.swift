//
//  DictsDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

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
    @IBOutlet weak var tfAutomation: NSTextField!
    @IBOutlet weak var tfAutoJump: NSTextField!
    @IBOutlet weak var tfDicttable: NSTextField!
    @IBOutlet weak var tfTransformWin: NSTextField!
    @IBOutlet weak var tfTransform: NSTextField!
    @IBOutlet weak var tfTemplate: NSTextField!
    @IBOutlet weak var tfTemplate2: NSTextField!

    let disposeBag = DisposeBag()

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

    @IBAction func okClicked(_ sender: Any) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
//        if isAdd {
//            DictsViewModel.create(item: item).subscribe {
//                self.complete?()
//            }.disposed(by: disposeBag)
//        } else {
//            DictsViewModel.update(item: item).subscribe {
//                self.complete?()
//            }.disposed(by: disposeBag)
//        }
        dismiss(self)
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
