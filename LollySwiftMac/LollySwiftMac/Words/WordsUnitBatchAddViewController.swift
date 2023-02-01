//
//  WordsUnitBatchAddViewController.swift
//  LollySwiftMac
//
//  Created by 趙　偉 on 2021/01/06.
//  Copyright © 2021 趙偉. All rights reserved.
//

import Cocoa
import Combine

class WordsUnitBatchAddViewController: NSViewController {

    @IBOutlet weak var acUnits: NSArrayController!
    @IBOutlet weak var acParts: NSArrayController!
    @IBOutlet weak var pubUnit: NSPopUpButton!
    @IBOutlet weak var pubPart: NSPopUpButton!
    @IBOutlet weak var tvWords: NSTextView!
    @IBOutlet weak var btnOK: NSButton!

    var vm: WordsUnitViewModel!
    var vmEdit: WordsUnitBatchAddViewModel!
    var item: MUnitWord { vmEdit.item }
    var itemEdit: MUnitWordEdit { vmEdit.itemEdit }
    var complete: (() -> Void)?
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        acUnits.content = item.textbook.arrUnits
        acParts.content = item.textbook.arrParts
        itemEdit.$indexUNIT <~> pubUnit.selectedItemIndexProperty ~ subscriptions
        itemEdit.$indexPART <~> pubPart.selectedItemIndexProperty ~ subscriptions
        itemEdit.$WORDS <~> tvWords.textProperty ~ subscriptions
        btnOK.tapPublisher.sink { [unowned self] in
            Task {
                await vmEdit.onOK()
                complete?()
                dismiss(btnOK)
            }
        } ~ subscriptions
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.title = "Batch Add"
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
