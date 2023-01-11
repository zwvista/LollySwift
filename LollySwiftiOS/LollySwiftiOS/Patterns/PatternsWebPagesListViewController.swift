//
//  PatternsWebPagesListViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import WebKit
import Combine

class PatternsWebPagesListViewController: UITableViewController {

    @IBOutlet weak var btnEdit: UIBarButtonItem!

    var vm: PatternsWebPagesViewModel!
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        refresh(refreshControl!)
    }

    @objc func refresh(_ sender: UIRefreshControl) {
        Task {
            await vm.getWebPages()
            sender.endRefreshing()
            self.tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.arrWebPages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WebPageCell10", for: indexPath) as! WebPagesCell
        let item = vm.arrWebPages[indexPath.row]
        cell.lblSeqNum!.text = String(item.SEQNUM)
        cell.lblTitle!.text = item.TITLE
        cell.lblURL!.text = item.URL
        cell.cardView.createCardEffect()
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        vm.currentWebPageIndex = indexPath.row
        if tableView.isEditing {
            performSegue(withIdentifier: "edit", sender: vm.currentWebPage)
        } else {
            AppDelegate.speak(string: vm.currentWebPage.TITLE)
        }
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }

    private func reindex() {
        tableView.beginUpdates()
        Task {
            await vm.reindexWebPage {
                self.tableView.reloadRows(at: [IndexPath(row: $0, section: 0)], with: .fade)
            }
            tableView.endUpdates()
        }
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        vm.arrWebPages.moveElement(at: sourceIndexPath.row, to: destinationIndexPath.row)
        reindex()
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let i = indexPath.row
        let item = vm.arrWebPages[i]
        func edit() {
            performSegue(withIdentifier: "edit", sender: item)
        }
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _,_,_ in edit() }
        editAction.backgroundColor = .blue
        return UISwipeActionsConfiguration(actions: [editAction])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? PatternsWebPagesDetailViewController {
            let item = segue.identifier == "add" ? vm.newPatternWebPage() : vm.currentWebPage
            controller.vmEdit = PatternsWebPagesDetailViewModel(item: item)
        }
    }

    @IBAction func btnEditClicked(_ sender: AnyObject) {
        tableView.isEditing = !tableView.isEditing
        btnEdit.title = tableView.isEditing ? "Done" : "Edit"
    }

    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "Done" else {return}
        if let controller = segue.source as? PatternsWebPagesDetailViewController {
            Task {
                await controller.vmEdit.onOK()
            }
        }
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
