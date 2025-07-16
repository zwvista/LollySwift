//
//  LangBlogPostsListViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2020/11/05.
//  Copyright © 2020 趙 偉. All rights reserved.
//

import UIKit
import Combine

class LangBlogPostsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sbPostFilter: UISearchBar!
    let refreshControl = UIRefreshControl()

    var vm: LangBlogGroupsViewModel!
    var arrPosts: [MLangBlogPost] { vm.arrPostsFiltered }
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        vm.$arrPostsFiltered.didSet.sink { [unowned self] _ in
            tableView.reloadData()
        } ~ subscriptions
        vm.$postFilter <~> sbPostFilter.searchTextField.textProperty ~ subscriptions

        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        refresh(refreshControl)
    }

    @objc func refresh(_ sender: UIRefreshControl) {
        view.showBlurLoader()
        Task {
            await vm.reloadPosts()
            sender.endRefreshing()
            view.removeBlurLoader()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrPosts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LangBlogPostsListCell", for: indexPath) as! LangBlogPostsListCell
        let item = arrPosts[indexPath.row]
        cell.lblTitle.text = item.TITLE
        cell.cardView.createCardEffect()
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = arrPosts[indexPath.row]
        if tableView.isEditing {
            performSegue(withIdentifier: "edit", sender: item)
        } else {
            AppDelegate.speak(string: item.TITLE)
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let i = indexPath.row
        let item = vm.arrPosts[i]
        func edit() {
            performSegue(withIdentifier: "edit", sender: item)
        }
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _,_,_ in edit() }
        editAction.backgroundColor = .blue
        let moreAction = UIContextualAction(style: .normal, title: "More") { [unowned self] _,_,_ in
            let alertController = UIAlertController(title: "Language Blog Posts", message: item.TITLE, preferredStyle: .alert)
            let editAction2 = UIAlertAction(title: "Edit", style: .default) { _ in edit() }
            alertController.addAction(editAction2)
            let browseContentAction = UIAlertAction(title: "Content", style: .default) { [unowned self] _ in
                performSegue(withIdentifier: "content", sender: item)
            }
            alertController.addAction(browseContentAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
            alertController.addAction(cancelAction)
            present(alertController, animated: true) {}
        }

        return UISwipeActionsConfiguration(actions: [moreAction])
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let item = arrPosts[indexPath.row]
        performSegue(withIdentifier: "content", sender: item)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? LangBlogPostsDetailViewController {
            controller.item = sender as? MLangBlogPost
        } else if let controller = segue.destination as? LangBlogPostsContentViewController {
            vm.selectedPost = sender as? MLangBlogPost
            let index = arrPosts.firstIndex(of: sender as! MLangBlogPost)!
            let (start, end) = getPreferredRangeFromArray(index: index, length: arrPosts.count, preferredLength: 50)
            controller.vm = LangBlogPostsContentViewModel(settings: vmSettings, arrLangBlogPosts: Array(arrPosts[start ..< end]), selectedLangBlogPostIndex: index) {}
            controller.vmGroups = vm
        }
    }

    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}

class LangBlogPostsListCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
}
