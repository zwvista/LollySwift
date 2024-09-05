//
//  OnlineTextbooksDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import RxBinding

class OnlineTextbooksDetailViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfOnlineTextbook: UITextField!
    @IBOutlet weak var tfUnit: UITextField!
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tfURL: UITextField!

    var item: MOnlineTextbook!

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.text = "\(item.ID)"
        tfOnlineTextbook.text = item.TEXTBOOKNAME
        tfUnit.text = "\(item.UNIT)"
        tfTitle.text = item.TITLE
        tfURL.text = item.URL
    }

    // https://stackoverflow.com/questions/21893649/how-to-make-a-uitextfield-selectable-but-not-editable
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        false
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
