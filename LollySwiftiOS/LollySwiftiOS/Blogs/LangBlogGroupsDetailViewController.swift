//
//  LangBlogGroupsDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class LangBlogGroupsDetailViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfGroupName: UITextField!

    var item: MLangBlogGroup!

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.text = "\(item.ID)"
        tfGroupName.text = item.GROUPNAME
    }

    // https://stackoverflow.com/questions/21893649/how-to-make-a-uitextfield-selectable-but-not-editable
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        false
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
