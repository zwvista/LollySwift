//
//  WordsLangDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class WordsLangDetailViewController: UITableViewController {
    
    var vm: WordsLangViewModel!
    var item: MLangWord!
    
    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfWord: UITextField!
    @IBOutlet weak var tfNote: UITextField!
    @IBOutlet weak var tfFamiID: UITextField!
    @IBOutlet weak var tfLevel: UITextField!
    @IBOutlet weak var tfAccuracy: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.text = String(item.ID)
        tfWord.text = item.WORD
        tfNote.text = item.NOTE
        tfFamiID.text = String(item.FAMIID)
        tfLevel.text = String(item.LEVEL)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // https://stackoverflow.com/questions/7525437/how-to-set-focus-to-a-textfield-in-iphone
        (item.WORD.isEmpty ? tfWord : tfNote).becomeFirstResponder()
    }

    func onDone() {
        item.WORD = vmSettings.autoCorrectInput(text: tfWord.text ?? "")
        item.NOTE = tfNote.text
        item.LEVEL = Int(tfLevel.text!)!
    }
    
    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
