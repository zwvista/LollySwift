//
//  OnlineTextbooksViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2020/11/05.
//  Copyright © 2020 趙 偉. All rights reserved.
//

import UIKit
import Combine

class OnlineTextbooksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnOnlineTextbookFilter: UIButton!
    let refreshControl = UIRefreshControl()

    var vm: OnlineTextbooksViewModel!
    var arrOnlineTextbooks: [MOnlineTextbook] { vm.arrOnlineTextbooks }
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        refresh(refreshControl)
    }

    @objc func refresh(_ sender: UIRefreshControl) {
        view.showBlurLoader()
        vm = OnlineTextbooksViewModel(settings: vmSettings) { [unowned self] in
            sender.endRefreshing()
            view.removeBlurLoader()
        }
        vm.$stringOnlineTextbookFilter ~> (btnOnlineTextbookFilter, \.titleNormal) ~ subscriptions
        vm.$arrOnlineTextbooks.didSet.sink { [unowned self] _ in
            tableView.reloadData()
        } ~ subscriptions

        func configMenu() {
            btnOnlineTextbookFilter.menu = UIMenu(title: "", options: .displayInline, children: vmSettings.arrOnlineTextbookFilters.map(\.label).enumerated().map { index, item in
                UIAction(title: item, state: item == vm.stringOnlineTextbookFilter ? .on : .off) { [unowned self] _ in
                    vm.stringOnlineTextbookFilter = item
                    configMenu()
                }
            })
            btnOnlineTextbookFilter.showsMenuAsPrimaryAction = true
        }
        configMenu()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrOnlineTextbooks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OnlineTextbooksCell", for: indexPath) as! OnlineTextbooksCell
        let item = arrOnlineTextbooks[indexPath.row]
        cell.lblOnlineTextbook.text = item.TEXTBOOKNAME
        cell.lblTitle.text = item.TITLE
        cell.cardView.createCardEffect()
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = arrOnlineTextbooks[indexPath.row]
        if tableView.isEditing {
            performSegue(withIdentifier: "edit", sender: item)
        } else {
            AppDelegate.speak(string: item.TITLE)
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let i = indexPath.row
        let item = vm.arrOnlineTextbooks[i]
        func edit() {
            performSegue(withIdentifier: "edit", sender: item)
        }
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _,_,_ in edit() }
        editAction.backgroundColor = .blue
        let moreAction = UIContextualAction(style: .normal, title: "More") { [unowned self] _,_,_ in
            let alertController = UIAlertController(title: "Online Textbooks", message: item.TEXTBOOKNAME, preferredStyle: .alert)
            let editAction2 = UIAlertAction(title: "Edit", style: .default) { _ in edit() }
            alertController.addAction(editAction2)
            let browseWebPageAction = UIAlertAction(title: "Browse Web Page", style: .default) { [unowned self] _ in
                performSegue(withIdentifier: "browse page", sender: item)
            }
            alertController.addAction(browseWebPageAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
            alertController.addAction(cancelAction)
            present(alertController, animated: true) {}
        }

        return UISwipeActionsConfiguration(actions: [moreAction])
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let item = arrOnlineTextbooks[indexPath.row]
        performSegue(withIdentifier: "browse page", sender: item)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? OnlineTextbooksDetailViewController {
            controller.item = sender as? MOnlineTextbook
        } else if let controller = segue.destination as? OnlineTextbooksWebPageViewController {
            let index = arrOnlineTextbooks.firstIndex(of: sender as! MOnlineTextbook)!
            let (start, end) = getPreferredRangeFromArray(index: index, length: arrOnlineTextbooks.count, preferredLength: 50)
            controller.vm = OnlineTextbooksWebPageViewModel(settings: vmSettings, arrOnlineTextbooks:  Array(arrOnlineTextbooks[start ..< end]), selectedOnlineTextbookIndex: index) {}
        }
    }

    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}

class OnlineTextbooksCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var lblOnlineTextbook: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
}
