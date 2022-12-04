//
//  PhrasesUnitBatchAddViewController.swift
//  LollySwiftMac
//
//  Created by 趙　偉 on 2021/01/06.
//  Copyright © 2021 趙偉. All rights reserved.
//

import Cocoa
import Combine

class PhrasesUnitBatchAddViewController: NSViewController {
    
    var vm: PhrasesUnitViewModel!
    var vmEdit: PhrasesUnitBatchAddViewModel!
    var item: MUnitPhrase { vmEdit.item }
    var itemEdit: MUnitPhraseEdit { vmEdit.itemEdit }
    var complete: (() -> Void)?
    
    @IBOutlet weak var acUnits: NSArrayController!
    @IBOutlet weak var acParts: NSArrayController!
    @IBOutlet weak var pubUnit: NSPopUpButton!
    @IBOutlet weak var pubPart: NSPopUpButton!
    @IBOutlet weak var tvPhrases: NSTextView!
    @IBOutlet weak var btnOK: NSButton!
    
    func startEdit(vm: PhrasesUnitViewModel) {
        vmEdit = PhrasesUnitBatchAddViewModel(vm: vm)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        acUnits.content = item.textbook.arrUnits
        acParts.content = item.textbook.arrParts
        _ = itemEdit.indexUNIT <~> pubUnit.rx.selectedItemIndex
        _ = itemEdit.indexPART <~> pubPart.rx.selectedItemIndex
        _ = itemEdit.PHRASES <~> tvPhrases.rx.string
        btnOK.rx.tap.flatMap { [unowned self] _ in
            self.vmEdit.onOK()
        }.subscribe { [unowned self] _ in
            self.complete?()
            self.dismiss(self.btnOK)
        } ~ rx.disposeBag
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.title = "Batch Add"
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
