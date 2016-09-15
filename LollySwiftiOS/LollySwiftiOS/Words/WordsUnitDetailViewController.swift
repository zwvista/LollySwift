//
//  WordsUnitDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class WordsUnitDetailViewController: UITableViewController {
    
    var mWord: MUnitWord!
    var mTextbook: MTextbook {
        return AppDelegate.theSettingsViewModel.selectedTextbook
    }
    
    @IBOutlet weak var tfUnit: UITextField!
    @IBOutlet weak var tfPart: UITextField!
    @IBOutlet weak var tfSeqNum: UITextField!
    @IBOutlet weak var tfWord: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
                
        tfUnit.text = String(mWord.UNIT)
        tfPart.text = String(mWord.PART)
        tfSeqNum.text = String(mWord.SEQNUM)
        tfWord.text = mWord.WORD
    }
    
    @IBAction func onCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDone(_ sender: AnyObject) {
        mWord.UNIT = Int(tfUnit.text!)!
        mWord.PART = Int(tfPart.text!)!
        mWord.SEQNUM = Int(tfSeqNum.text!)!
        mWord.WORD = tfWord.text
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
