//
//  WordsTextbookDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import RxSwift
import RxBinding

class WordsTextbookDetailViewController: UITableViewController {

    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfTextbookName: UITextField!
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
                    itemEdit.indexUNIT = index ?? -1
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
                    itemEdit.indexPART = index ?? -1
                    itemEdit.PARTSTR = item
                    configMenuPart()
                }
            })
            btnPart.showsMenuAsPrimaryAction = true
        }
        configMenuPart()

        _ = itemEdit.ID ~> tfID.rx.text.orEmpty
        _ = itemEdit.TEXTBOOKNAME ~> tfTextbookName.rx.text.orEmpty
        _ = itemEdit.UNITSTR_ <~> tfUnit.rx.textInput
        _ = itemEdit.PARTSTR_ <~> tfPart.rx.textInput
        _ = itemEdit.SEQNUM <~> tfSeqNum.rx.textInput
        _ = itemEdit.WORDID ~> tfWordID.rx.text
        _ = itemEdit.WORD <~> tfWord.rx.textInput
        _ = itemEdit.NOTE <~> tfNote.rx.textInput
        _ = itemEdit.FAMIID ~> tfFamiID.rx.text
        _ = itemEdit.ACCURACY ~> tfAccuracy.rx.text
        _ = vmEdit.isOKEnabled ~> btnDone.rx.isEnabled
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
