//
//  TextbooksDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

class TextbooksDetailViewController: NSViewController {

    var vm: TextbooksViewModel!
    var complete: (() -> Void)?
    @objc var item: MTextbook!
    var isAdd: Bool!

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfLang: NSTextField!
    @IBOutlet weak var tfTextbookName: NSTextField!
    @IBOutlet weak var tfUnits: NSTextField!
    @IBOutlet weak var tfParts: NSTextField!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        isAdd = item.ID == 0
    }
    
    override func viewDidAppear() {
        view.window?.title = item.TEXTBOOKNAME
        tfID.isEnabled = isAdd
        tfLang.stringValue = vm.vmSettings.selectedLang.LANGNAME
        (isAdd ? tfID : tfTextbookName).becomeFirstResponder()
    }

    @IBAction func okClicked(_ sender: Any) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        if isAdd {
            TextbooksViewModel.create(item: item).subscribe {
                self.complete?()
            }.disposed(by: disposeBag)
        } else {
            TextbooksViewModel.update(item: item).subscribe {
                self.complete?()
            }.disposed(by: disposeBag)
        }
        dismiss(self)
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
