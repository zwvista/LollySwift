//
//  PhrasesUnitBatchAddViewController.swift
//  LollySwiftMac
//
//  Created by 趙　偉 on 2021/01/06.
//  Copyright © 2021 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import RxBinding

class PhrasesUnitBatchAddViewController: NSViewController {

    @IBOutlet weak var acUnits: NSArrayController!
    @IBOutlet weak var acParts: NSArrayController!
    @IBOutlet weak var pubUnit: NSPopUpButton!
    @IBOutlet weak var pubPart: NSPopUpButton!
    @IBOutlet weak var tvPhrases: NSTextView!
    @IBOutlet weak var btnOK: NSButton!

    var vm: PhrasesUnitViewModel!
    var vmEdit: PhrasesUnitBatchAddViewModel!
    var item: MUnitPhrase { vmEdit.item }
    var itemEdit: MUnitPhraseEdit { vmEdit.itemEdit }
    var complete: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        acUnits.content = item.textbook.arrUnits
        acParts.content = item.textbook.arrParts
        _ = itemEdit.indexUNIT_ <~> pubUnit.rx.selectedItemIndex
        _ = itemEdit.indexPART_ <~> pubPart.rx.selectedItemIndex
        _ = itemEdit.PHRASES <~> tvPhrases.rx.string
        btnOK.rx.tap.flatMap { [unowned self] in
            vmEdit.onOK()
        }.subscribe { [unowned self] _ in
            complete?()
            dismiss(btnOK)
        } ~ rx.disposeBag
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.title = "Batch Add"
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
