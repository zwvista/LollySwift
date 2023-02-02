//
//  PhrasesTextbookDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import Combine

class PhrasesTextbookDetailViewController: UITableViewController {

    @IBOutlet weak var tfTextbookName: UITextField!
    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfUnit: UITextField!
    @IBOutlet weak var btnUnit: UIButton!
    @IBOutlet weak var tfPart: UITextField!
    @IBOutlet weak var btnPart: UIButton!
    @IBOutlet weak var tfSeqNum: UITextField!
    @IBOutlet weak var tfPhraseID: UITextField!
    @IBOutlet weak var tfPhrase: UITextField!
    @IBOutlet weak var tfTranslation: UITextField!
    @IBOutlet weak var btnDone: UIBarButtonItem!

    var vmEdit: PhrasesUnitDetailViewModel!
    var item: MUnitPhrase { vmEdit.item }
    var itemEdit: MUnitPhraseEdit { vmEdit.itemEdit }
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        func configMenuUnit() {
            btnUnit.menu = UIMenu(title: "", options: .displayInline, children: vmSettings.arrUnits.map(\.label).enumerated().map { index, item in
                UIAction(title: item, state: index == itemEdit.indexUNIT ? .on : .off) { [unowned self] _ in
                    itemEdit.indexUNIT = index
                    itemEdit.UNITSTR = item
                    configMenuUnit()
                }
            })
            btnUnit.showsMenuAsPrimaryAction = true
        }
        configMenuUnit()

        func configMenuPart() {
            btnPart.menu = UIMenu(title: "", options: .displayInline, children: vmSettings.arrParts.map(\.label).enumerated().map { index, item in
                UIAction(title: item, state: index == itemEdit.indexPART ? .on : .off) { [unowned self] _ in
                    itemEdit.indexPART = index
                    itemEdit.PARTSTR = item
                    configMenuPart()
                }
            })
            btnPart.showsMenuAsPrimaryAction = true
        }
        configMenuPart()

        tfID.text = itemEdit.ID
        tfTextbookName.text = itemEdit.TEXTBOOKNAME
        itemEdit.$UNITSTR <~> tfUnit.textProperty ~ subscriptions
        itemEdit.$PARTSTR <~> tfPart.textProperty ~ subscriptions
        itemEdit.$SEQNUM <~> tfSeqNum.textProperty ~ subscriptions
        tfPhraseID.text = itemEdit.PHRASEID
        itemEdit.$PHRASE <~> tfPhrase.textProperty ~ subscriptions
        itemEdit.$TRANSLATION <~> tfTranslation.textProperty ~ subscriptions
        vmEdit.$isOKEnabled ~> (btnDone, \.isEnabled) ~ subscriptions
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // https://stackoverflow.com/questions/7525437/how-to-set-focus-to-a-textfield-in-iphone
        (item.PHRASE.isEmpty ? tfPhrase : tfTranslation).becomeFirstResponder()
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
