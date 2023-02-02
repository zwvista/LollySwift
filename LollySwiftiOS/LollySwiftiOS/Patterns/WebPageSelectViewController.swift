//
//  WebPageSelectViewController.swift
//  LollySwiftiOS
//
//  Created by 趙　偉 on 2020/12/16.
//  Copyright © 2020 趙 偉. All rights reserved.
//

import UIKit
import Combine

class WebPageSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tvSearch: UITableView!
    @IBOutlet weak var tvWebPages: UITableView!
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tfURL: UITextField!

    var vmWebPage: WebPageSelectViewModel!
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        vmWebPage = WebPageSelectViewModel(settings: vmSettings) { [unowned self] in
            tvWebPages.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView === tvSearch ? 2 : vmWebPage.arrWebPages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "WebPageCell" + (tableView === tvSearch ? "0\(indexPath.row)" : "10")
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! WebPagesCell
        if tableView === tvSearch {
            switch indexPath.row {
            case 0:
                tfTitle = cell.tf
                vmWebPage.$title <~> tfTitle.textProperty ~ subscriptions
            case 1:
                tfURL = cell.tf
                vmWebPage.$url <~> tfURL.textProperty ~ subscriptions
            default: break
            }
        } else {
            let item = vmWebPage.arrWebPages[indexPath.row]
            cell.lblTitle!.text = item.TITLE
            cell.lblURL!.text = item.URL
         }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        vmWebPage.selectedWebPage = vmWebPage.arrWebPages[indexPath.row]
        performSegue(withIdentifier: "close", sender: self)
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}

class WebPagesCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var lblSeqNum: UILabel!
    @IBOutlet weak var tf: UITextField!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblURL: UILabel!
}
