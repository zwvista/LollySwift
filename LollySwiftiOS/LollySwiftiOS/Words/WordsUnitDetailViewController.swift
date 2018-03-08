//
//  WordsUnitDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class WordsUnitDetailViewController: UITableViewController {
    
    var vm: WordsUnitViewModel!    
    var mWord: MUnitWord!
    
    @IBOutlet weak var tfUnit: UITextField!
    @IBOutlet weak var tfPart: UITextField!
    @IBOutlet weak var tfSeqNum: UITextField!
    @IBOutlet weak var tfWord: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
                
        tfUnit.text = String(mWord.UNIT!)
        tfPart.text = String(mWord.PART!)
        tfSeqNum.text = String(mWord.SEQNUM!)
        tfWord.text = mWord.WORD
    }
    
    func onDone() {
        mWord.UNIT = Int(tfUnit.text!)!
        mWord.PART = Int(tfPart.text!)!
        mWord.SEQNUM = Int(tfSeqNum.text!)!
        mWord.WORD = tfWord.text
        
        if mWord.ID == 0 {
            vm.arrWords.append(mWord)
        }
    }
    
}
