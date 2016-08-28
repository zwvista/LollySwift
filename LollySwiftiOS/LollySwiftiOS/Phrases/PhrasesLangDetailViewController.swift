//
//  PhrasesLangDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class PhrasesLangDetailViewController: UITableViewController {
    
    var mPhrase: MLangPhrase!
    
    @IBOutlet weak var tfPhrase: UITextField!
    @IBOutlet weak var tfTranslation: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        tfPhrase.text = mPhrase.PHRASE
        tfTranslation.text = mPhrase.TRANSLATION
    }
    
    @IBAction func onCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onDone(sender: AnyObject) {
        mPhrase.PHRASE = tfPhrase.text
        mPhrase.TRANSLATION = tfTranslation.text
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}