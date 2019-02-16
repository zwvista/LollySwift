//
//  PhrasesTextbookDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class PhrasesTextbookDetailViewController: UITableViewController {
    
    var vm: PhrasesTextbookViewModel!
    var item: MTextbookPhrase!
    
    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfPhrase: UITextField!
    @IBOutlet weak var tfTranslation: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        tfPhrase.text = item.PHRASE
        tfTranslation.text = item.TRANSLATION
    }
    
    func onDone() {
        item.PHRASE = vm.vmSettings.autoCorrectInput(text: tfPhrase.text ?? "")
        item.TRANSLATION = tfTranslation.text
    }
    
}
