//
//  PatternsViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2020/11/05.
//  Copyright © 2020 趙 偉. All rights reserved.
//

import UIKit
import RxSwift
import NSObject_Rx

class PatternsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var vm: PatternsViewModel!
    var arrPatterns: [MPattern] { vm.arrPatterns }
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm = PatternsViewModel(settings: vmSettings, needCopy: false) {
            self.tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrPatterns.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatternCell", for: indexPath) as! PatternsCell
        let item = arrPatterns[indexPath.row]
        cell.lblPattern.text = item.PATTERN
        return cell
    }


    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}

class PatternsCell: UITableViewCell {
    @IBOutlet weak var lblPattern: UILabel!
}
