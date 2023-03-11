//
//  WebTextbooksDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import RxBinding

class WebTextbooksDetailViewController: UITableViewController {

    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfWebTextbook: UITextField!
    @IBOutlet weak var tfUnit: UITextField!
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tfURL: UITextField!
    @IBOutlet weak var btnDone: UIBarButtonItem!

    var item: MWebTextbook!

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.text = "\(item.ID)"
        tfWebTextbook.text = item.TEXTBOOKNAME
        tfUnit.text = "\(item.UNIT)"
        tfTitle.text = item.TITLE
        tfURL.text = item.URL
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
