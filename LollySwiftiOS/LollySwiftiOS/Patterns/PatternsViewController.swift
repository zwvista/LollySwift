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

class PatternsViewController: UITableViewController {
    
    var vm: PatternsViewModel!
    var arrPatterns: [MPattern] { vm.arrPatterns }

    override func viewDidLoad() {
        super.viewDidLoad()
        vm = PatternsViewModel(settings: vmSettings, needCopy: false) {
            self.tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrPatterns.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatternCell", for: indexPath)
        let item = arrPatterns[indexPath.row]
        cell.textLabel?.text = item.PATTERN
        return cell
    }


    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
