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
    
    @IBOutlet weak var tfWord: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        tfWord.text = mWord.WORD
    }
    
    @IBAction func onCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDone(_ sender: AnyObject) {
        mWord.WORD = tfWord.text
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
