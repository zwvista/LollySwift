//
//  PhrasesLangDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import Combine

class PhrasesLangDetailViewController: UITableViewController {
    
    var vm: PhrasesLangViewModel!
    var item: MLangPhrase!
    var vmEdit: PhrasesLangDetailViewModel!
    var itemEdit: MLangPhraseEdit { vmEdit.itemEdit }

    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfPhrase: UITextField!
    @IBOutlet weak var tfTranslation: UITextField!
    @IBOutlet weak var btnDone: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = itemEdit.ID ~> tfID.rx.text.orEmpty
        _ = itemEdit.PHRASE <~> tfPhrase.rx.textInput
        _ = itemEdit.TRANSLATION <~> tfTranslation.rx.textInput
        _ = vmEdit.isOKEnabled ~> btnDone.rx.isEnabled
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // https://stackoverflow.com/questions/7525437/how-to-set-focus-to-a-textfield-in-iphone
        (vmEdit.isAdd ? tfPhrase : tfTranslation).becomeFirstResponder()
    }
    
    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
