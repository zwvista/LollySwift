//
//  PatternsViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2020/11/05.
//  Copyright © 2020 趙 偉. All rights reserved.
//

import UIKit
import Combine

class PatternsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sbTextFilter: UISearchBar!
    @IBOutlet weak var btnScopeFilter: UIButton!
    let refreshControl = UIRefreshControl()

    var vm: PatternsViewModel!
    var arrPatterns: [MPattern] { vm.arrPatternsFiltered }
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        refresh(refreshControl)

        func configMenu() {
            btnScopeFilter.menu = UIMenu(title: "", options: .displayInline, children: SettingsViewModel.arrScopePatternFilters.enumerated().map { index, item in
                UIAction(title: item, state: item == vm.scopeFilter ? .on : .off) { [unowned self] _ in
                    vm.scopeFilter = item
                    configMenu()
                }
            })
            btnScopeFilter.showsMenuAsPrimaryAction = true
        }
        configMenu()
    }

    @objc func refresh(_ sender: UIRefreshControl) {
        view.showBlurLoader()
        vm = PatternsViewModel(settings: vmSettings, needCopy: false) {
            sender.endRefreshing()
            self.view.removeBlurLoader()
        }
        vm.$textFilter <~> sbTextFilter.searchTextField.textProperty ~ subscriptions
        vm.$scopeFilter ~> (btnScopeFilter, \.titleNormal) ~ subscriptions
        vm.$arrPatternsFiltered.didSet.sink { [unowned self] _ in
            tableView.reloadData()
        } ~ subscriptions
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrPatterns.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatternCell", for: indexPath) as! PatternsCell
        let item = arrPatterns[indexPath.row]
        cell.lblPattern.text = item.PATTERN
        cell.lblTags.text = item.TAGS
        cell.cardView.createCardEffect()
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = arrPatterns[indexPath.row]
        if tableView.isEditing {
            performSegue(withIdentifier: "edit", sender: item)
        } else {
            AppDelegate.speak(string: item.PATTERN)
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let i = indexPath.row
        let item = vm.arrPatterns[i]
        func delete() {
            yesNoAction(title: "delete", message: "Do you really want to delete the pattern \"\(item.PATTERN)\"?", yesHandler: { (action) in
                Task {
                    await PatternsViewModel.delete(item.ID)
                }
                self.vm.arrPatterns.remove(at: i)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }, noHandler: { (action) in
                tableView.reloadRows(at: [indexPath], with: .fade)
            })
        }
        func edit() {
            performSegue(withIdentifier: "edit", sender: item)
        }
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _,_,_ in delete() }
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _,_,_ in edit() }
        editAction.backgroundColor = .blue
        let moreAction = UIContextualAction(style: .normal, title: "More") { [unowned self] _,_,_ in
            let alertController = UIAlertController(title: "Pattern", message: item.PATTERN, preferredStyle: .alert)
            let deleteAction2 = UIAlertAction(title: "Delete", style: .destructive) { _ in delete() }
            alertController.addAction(deleteAction2)
            let editAction2 = UIAlertAction(title: "Edit", style: .default) { _ in edit() }
            alertController.addAction(editAction2)
            let browseWebPagesAction = UIAlertAction(title: "Browse Web Pages", style: .default) { [unowned self] _ in
                performSegue(withIdentifier: "browse pages", sender: item)
            }
            alertController.addAction(browseWebPagesAction)
            let editWebPagesAction = UIAlertAction(title: "Edit Web Pages", style: .default) { [unowned self] _ in
                performSegue(withIdentifier: "edit pages", sender: item)
            }
            alertController.addAction(editWebPagesAction)
            let copyPatternAction = UIAlertAction(title: "Copy Pattern", style: .default) { _ in
                iOSApi.copyText(item.PATTERN)
            }
            alertController.addAction(copyPatternAction)
            let googlePatternAction = UIAlertAction(title: "Google Pattern", style: .default) { _ in
                iOSApi.googleString(item.PATTERN)
            }
            alertController.addAction(googlePatternAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true) {}
        }

        return UISwipeActionsConfiguration(actions: [moreAction, deleteAction])
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let item = arrPatterns[indexPath.row]
        performSegue(withIdentifier: "browse pages", sender: item)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? PatternsDetailViewController {
            let item = segue.identifier == "add" ? vm.newPattern() : sender as! MPattern
            controller.vmEdit = PatternsDetailViewModel(vm: vm, item: item)
        } else if let controller = segue.destination as? PatternsWebPagesBrowseViewController {
            controller.vm = PatternsWebPagesViewModel(settings: vmSettings, needCopy: false, item: sender as? MPattern)
        } else if let controller = segue.destination as? PatternsWebPagesListViewController {
            controller.vm = PatternsWebPagesViewModel(settings: vmSettings, needCopy: false, item: sender as? MPattern)
        }
    }

    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "Done" else {return}
        if let controller = segue.source as? PatternsDetailViewController {
            Task {
                await controller.vmEdit.onOK()
                self.tableView.reloadData()
                if controller.vmEdit.isAdd {
                    self.performSegue(withIdentifier: "add", sender: self)
                }
            }
        }
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}

class PatternsCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var lblPattern: UILabel!
    @IBOutlet weak var lblTags: UILabel!
}
