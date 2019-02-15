//
//  WordsTextbookDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class WordsTextbookDetailViewController: UITableViewController {
    
    var vm: WordsTextbookViewModel!
    var mWord: MTextbookWord!
    
    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfWord: UITextField!
    @IBOutlet weak var tfNote: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        tfWord.text = mWord.WORD
        tfNote.text = mWord.NOTE
    }
    
    func onDone() {
        mWord.WORD = vm.vmSettings.autoCorrectInput(text: tfWord.text ?? "")
        mWord.NOTE = tfNote.text
    }
    
}
