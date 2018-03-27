//
//  PhrasesUnitDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class PhrasesUnitDetailViewController: UITableViewController {
    
    var vm: PhrasesUnitViewModel!
    var mPhrase: MUnitPhrase!
    
    @IBOutlet weak var tfUnit: UITextField!
    @IBOutlet weak var tfPart: UITextField!
    @IBOutlet weak var tfSeqNum: UITextField!
    @IBOutlet weak var tfPhrase: UITextField!
    @IBOutlet weak var tfTranslation: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        tfUnit.text = String(mPhrase.UNIT)
        tfPart.text = String(mPhrase.PART)
        tfSeqNum.text = String(mPhrase.SEQNUM)
        tfPhrase.text = mPhrase.PHRASE
        tfTranslation.text = mPhrase.TRANSLATION
    }
    
    func onDone() {
        mPhrase.UNIT = Int(tfUnit.text!)!
        mPhrase.PART = Int(tfPart.text!)!
        mPhrase.SEQNUM = Int(tfSeqNum.text!)!
        mPhrase.PHRASE = tfPhrase.text!
        mPhrase.TRANSLATION = tfTranslation.text
        
        if mPhrase.ID == 0 {
            vm.arrPhrases.append(mPhrase)
            PhrasesUnitViewModel.create(m: MUnitPhraseEdit(m: mPhrase)) { self.mPhrase.ID = $0 }
        } else {
            PhrasesUnitViewModel.update(mPhrase.ID, m: MUnitPhraseEdit(m: mPhrase)) {}
        }
    }
    
}
