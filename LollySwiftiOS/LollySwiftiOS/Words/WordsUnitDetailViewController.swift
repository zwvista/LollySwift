//
//  WordsUnitDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import Combine

class WordsUnitDetailViewController: UITableViewController {

    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfUnit: UITextField!
    @IBOutlet weak var btnUnit: UIButton!
    @IBOutlet weak var tfPart: UITextField!
    @IBOutlet weak var btnPart: UIButton!
    @IBOutlet weak var tfSeqNum: UITextField!
    @IBOutlet weak var tfWordID: UITextField!
    @IBOutlet weak var tfWord: UITextField!
    @IBOutlet weak var tfNote: UITextField!
    @IBOutlet weak var tfFamiID: UITextField!
    @IBOutlet weak var tfAccuracy: UITextField!
    @IBOutlet weak var btnDone: UIBarButtonItem!

    var vmEdit: WordsUnitDetailViewModel!
    var item: MUnitWord { vmEdit.item }
    var itemEdit: MUnitWordEdit { vmEdit.itemEdit }
    var subscriptions = Set<AnyCancellable>()

    func startEdit(vm: WordsUnitViewModel, item: MUnitWord, phraseid: Int) {
        vmEdit = WordsUnitDetailViewModel(vm: vm, item: item, phraseid: phraseid) {
            self.tableView.reloadData()
        }
    }

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
        itemEdit.$UNITSTR <~> tfUnit.textProperty ~ subscriptions
        itemEdit.$PARTSTR <~> tfPart.textProperty ~ subscriptions
        itemEdit.$SEQNUM <~> tfSeqNum.textProperty ~ subscriptions
        tfWordID.text = itemEdit.WORDID
        itemEdit.$WORD <~> tfWord.textProperty ~ subscriptions
        itemEdit.$NOTE <~> tfNote.textProperty ~ subscriptions
        tfFamiID.text = itemEdit.FAMIID
        itemEdit.$ACCURACY ~> (tfAccuracy, \.text2) ~ subscriptions
        vmEdit.$isOKEnabled ~> (btnDone, \.isEnabled) ~ subscriptions
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // https://stackoverflow.com/questions/7525437/how-to-set-focus-to-a-textfield-in-iphone
        (vmEdit.isAdd ? tfWord : tfNote).becomeFirstResponder()
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
