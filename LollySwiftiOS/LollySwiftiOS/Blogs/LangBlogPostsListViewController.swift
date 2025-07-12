//
//  LangBlogPostsViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2020/11/05.
//  Copyright © 2020 趙 偉. All rights reserved.
//

import UIKit
import Combine

class LangBlogPostsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    let refreshControl = UIRefreshControl()

    var vm: LangBlogGroupsViewModel!
    var arrGroups: [MLangBlogGroup] { vm.arrGroups }
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        refresh(refreshControl)
    }

    @objc func refresh(_ sender: UIRefreshControl) {
        view.showBlurLoader()
        vm = LangBlogGroupsViewModel(settings: vmSettings) { [unowned self] in
            sender.endRefreshing()
            view.removeBlurLoader()
        }
        vm.$arrGroups.didSet.sink { [unowned self] _ in
            tableView.reloadData()
        } ~ subscriptions
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrGroups.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LangBlogPostsCell", for: indexPath) as! LangBlogPostsCell
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
        let item = vm.arrGroups[i]
        func edit() {
            performSegue(withIdentifier: "edit", sender: item)
        }
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _,_,_ in edit() }
        editAction.backgroundColor = .blue
        let moreAction = UIContextualAction(style: .normal, title: "More") { [unowned self] _,_,_ in
            let alertController = UIAlertController(title: "Language Blog Groups", message: item.GROUPNAME, preferredStyle: .alert)
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
        let item = arrGroups[indexPath.row]
        performSegue(withIdentifier: "browse page", sender: item)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? LangBlogPostsDetailViewController {
            controller.item = sender as? MLangBlogGroup
        }
//        else if let controller = segue.destination as? LangBlogGroupsWebPageViewController {
//            let index = arrGroups.firstIndex(of: sender as! MLangBlogGroup)!
//            let (start, end) = getPreferredRangeFromArray(index: index, length: arrGroups.count, preferredLength: 50)
//            controller.vm = LangBlogGroupsWebPageViewModel(settings: vmSettings, arrGroups:  Array(arrGroups[start ..< end]), currentLangBlogGroupIndex: index) {}
//        }
    }

    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}

class LangBlogPostsCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
}
