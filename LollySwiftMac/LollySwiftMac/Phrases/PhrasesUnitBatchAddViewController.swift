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
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        acUnits.content = item.textbook.arrUnits
        acParts.content = item.textbook.arrParts
        itemEdit.$indexUNIT <~> pubUnit.selectedItemIndexProperty ~ subscriptions
        itemEdit.$indexPART <~> pubPart.selectedItemIndexProperty ~ subscriptions
        itemEdit.$PHRASES <~> tvPhrases.textProperty ~ subscriptions
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
