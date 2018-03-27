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
    
    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfPhrase: UITextField!
    @IBOutlet weak var tfTranslation: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.text = String(mPhrase.ID)
        tfPhrase.text = mPhrase.PHRASE
        tfTranslation.text = mPhrase.TRANSLATION
    }
    
    func onDone() {
        mPhrase.PHRASE = tfPhrase.text ?? ""
        mPhrase.TRANSLATION = tfTranslation.text
    }
    
}
