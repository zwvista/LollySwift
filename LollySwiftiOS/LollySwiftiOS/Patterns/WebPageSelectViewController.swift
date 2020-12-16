//
//  WebPageSelectViewController.swift
//  LollySwiftiOS
//
//  Created by 趙　偉 on 2020/12/16.
//  Copyright © 2020 趙 偉. All rights reserved.
//

import UIKit

class WebPageSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tvSearch: UITableView!
    @IBOutlet weak var tvWebPages: UITableView!
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tfURL: UITextField!

    var vm: WebPageSelectViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        vm = WebPageSelectViewModel(settings: vmSettings) {
            self.tvWebPages.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView === tvSearch ? 2 : vm.arrWebPages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "WebPageCell" + (tableView === tvSearch ? "0\(indexPath.row)" : "10")
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! WebPagesCell
        if tableView === tvSearch {
            switch indexPath.row {
            case 0:
                tfTitle = cell.tf
            case 1:
                tfURL = cell.tf
            default: break
            }
        } else {
            let item = vm.arrWebPages[indexPath.row]
            cell.lblTitle!.text = item.TITLE
            cell.lblURL!.text = item.URL
         }
        return cell
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}

class WebPagesCell: UITableViewCell {
    @IBOutlet weak var tf: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblURL: UILabel!
}
