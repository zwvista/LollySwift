//
//  WordsLangDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class WordsLangDetailViewController: UITableViewController {
    
    var mWord: MLangWord!
    
    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfWord: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.text = String(mWord.ID)
        tfWord.text = mWord.WORD
    }
    
    func onDone() {
        mWord.WORD = tfWord.text ?? ""
    }
    
}
