//
//  PatternsWebPagesEditViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import NSObject_Rx

class PatternsWebPagesEditViewController: UITableViewController {
    
    var vm: PatternsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        vm.getWebPages().subscribe(onNext: {
        }) ~ rx.disposeBag
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.arrWebPages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WebPageCell10", for: indexPath) as! WebPagesCell
        let item = vm.arrWebPages[indexPath.row]
        cell.lblSeqNum!.text = item.SEQNUM.toString
        cell.lblTitle!.text = item.TITLE
        cell.lblURL!.text = item.URL
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? PatternsWebPageEditViewController {
            let item = segue.identifier == "add" ? vm.newPatternWebPage() : vm.currentWebPage
            controller.startEdit(item: item)
        }
    }

    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "Done" else {return}
        if let controller = segue.source as? PatternsWebPageEditViewController {
            controller.vmEdit.onOK().subscribe(onNext: {
            }) ~ rx.disposeBag
        }
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
