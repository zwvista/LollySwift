//
//  LangBlogGroupsViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2020/11/05.
//  Copyright © 2020 趙 偉. All rights reserved.
//

import UIKit
import RxSwift
import NSObject_Rx
import RxBinding

class LangBlogGroupsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sbGroupFilter: UISearchBar!
    let refreshControl = UIRefreshControl()

    var vm = LangBlogGroupsViewModel()
    var arrGroups: [MLangBlogGroup] { vm.arrGroups }

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.arrGroups_.subscribe { [unowned self] _ in
            tableView.reloadData()
        } ~ rx.disposeBag
        _ = vm.groupFilter_ <~> sbGroupFilter.searchTextField.rx.textInput

        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        refresh(refreshControl)
    }

    @objc func refresh(_ sender: UIRefreshControl) {
        view.showBlurLoader()
        vm.reloadGroups().subscribe { [unowned self] in
            sender.endRefreshing()
            view.removeBlurLoader()
        } ~ rx.disposeBag
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrGroups.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LangBlogGroupsCell", for: indexPath) as! LangBlogGroupsCell
        let item = arrGroups[indexPath.row]
        cell.lblTitle.text = item.GROUPNAME
        cell.cardView.createCardEffect()
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = arrGroups[indexPath.row]
        if tableView.isEditing {
            performSegue(withIdentifier: "edit", sender: item)
        } else {
            AppDelegate.speak(string: item.GROUPNAME)
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let i = indexPath.row
        let item = vm.arrGroupsAll[i]
        func edit() {
            performSegue(withIdentifier: "edit", sender: item)
        }
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _,_,_ in edit() }
        editAction.backgroundColor = .blue
        let moreAction = UIContextualAction(style: .normal, title: "More") { [unowned self] _,_,_ in
            let alertController = UIAlertController(title: "Language Blog Groups", message: item.GROUPNAME, preferredStyle: .alert)
            let editAction2 = UIAlertAction(title: "Edit", style: .default) { _ in edit() }
            alertController.addAction(editAction2)
            let postsAction = UIAlertAction(title: "Posts", style: .default) { [unowned self] _ in
                performSegue(withIdentifier: "posts", sender: item)
            }
            alertController.addAction(postsAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
            alertController.addAction(cancelAction)
            present(alertController, animated: true) {}
        }

        return UISwipeActionsConfiguration(actions: [moreAction])
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let item = arrGroups[indexPath.row]
        performSegue(withIdentifier: "posts", sender: item)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? LangBlogGroupsDetailViewController {
            controller.item = sender as? MLangBlogGroup
        } else if let controller = segue.destination as? LangBlogPostsListViewController {
            vm.selectedGroup = sender as? MLangBlogGroup
            controller.vm = vm
        }
    }

    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}

class LangBlogGroupsCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
}
