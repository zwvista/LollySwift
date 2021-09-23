//
//  WordsUnitBatchAddViewController.swift
//  LollySwiftMac
//
//  Created by 趙　偉 on 2021/01/06.
//  Copyright © 2021 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

class WordsUnitBatchAddViewController: NSViewController {
    
    var vm: WordsUnitViewModel!
    var vmEdit: WordsUnitBatchAddViewModel!
    var item: MUnitWord { vmEdit.item }
    var itemEdit: MUnitWordEdit { vmEdit.itemEdit }
    var complete: (() -> Void)?
    
    @IBOutlet weak var acUnits: NSArrayController!
    @IBOutlet weak var acParts: NSArrayController!
    @IBOutlet weak var pubUnit: NSPopUpButton!
    @IBOutlet weak var pubPart: NSPopUpButton!
    @IBOutlet weak var tvWords: NSTextView!
    @IBOutlet weak var btnOK: NSButton!
    
    func startEdit(vm: WordsUnitViewModel) {
        vmEdit = WordsUnitBatchAddViewModel(vm: vm)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        acUnits.content = item.textbook.arrUnits
        acParts.content = item.textbook.arrParts
        _ = itemEdit.indexUNIT <~> pubUnit.rx.selectedItemIndex
        _ = itemEdit.indexPART <~> pubPart.rx.selectedItemIndex
        _ = itemEdit.WORDS <~> tvWords.rx.string
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
