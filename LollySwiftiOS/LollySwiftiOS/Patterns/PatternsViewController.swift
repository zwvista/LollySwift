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
import RxBinding

class PatternsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sbTextFilter: UISearchBar!
    @IBOutlet weak var btnScopeFilter: UIButton!
    let refreshControl = UIRefreshControl()

    var vm = PatternsViewModel()
    var arrPatterns: [MPattern] { vm.arrPatterns }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = refreshControl
        refreshControl.rx.controlEvent(UIControl.Event.valueChanged).subscribe { [unowned self] in
            refresh()
        } ~ rx.disposeBag
        refresh()

        _ = vm.textFilter_ <~> sbTextFilter.searchTextField.rx.textInput
        _ = vm.scopeFilter_ ~> btnScopeFilter.rx.title(for: .normal)
        vm.arrPatterns_.subscribe { [unowned self] _ in
            tableView.reloadData()
        } ~ rx.disposeBag

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

    func refresh() {
        view.showBlurLoader()
        vm.reload().subscribe { [unowned self] in
            refreshControl.endRefreshing()
            view.removeBlurLoader()
        } ~ rx.disposeBag
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrPatterns.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatternsCell", for: indexPath) as! PatternsCell
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
        let item = vm.arrPatternsAll[i]
        func edit() {
            performSegue(withIdentifier: "edit", sender: item)
        }
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _,_,_ in edit() }
        editAction.backgroundColor = .blue
        let moreAction = UIContextualAction(style: .normal, title: "More") { [unowned self] _,_,_ in
            let alertController = UIAlertController(title: "Pattern", message: item.PATTERN, preferredStyle: .alert)
            let editAction2 = UIAlertAction(title: "Edit", style: .default) { _ in edit() }
            alertController.addAction(editAction2)
            let browseWebPageAction = UIAlertAction(title: "Browse Web Page", style: .default) { [unowned self] _ in
                performSegue(withIdentifier: "browse page", sender: item)
            }
            alertController.addAction(browseWebPageAction)
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
            present(alertController, animated: true) {}
        }

        return UISwipeActionsConfiguration(actions: [moreAction])
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let item = arrPatterns[indexPath.row]
        performSegue(withIdentifier: "browse page", sender: item)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? PatternsDetailViewController {
            let item = sender as! MPattern
            controller.item = item
        } else if let controller = segue.destination as? PatternsWebPageViewController {
            let index = arrPatterns.firstIndex(of: sender as! MPattern)!
            let (start, end) = getPreferredRangeFromArray(index: index, length: arrPatterns.count, preferredLength: 50)
            controller.vm = PatternsWebPageViewModel(arrPatterns:  Array(arrPatterns[start ..< end]), selectedPatternIndex: index)
        }
    }

    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}

class PatternsCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var lblPattern: UILabel!
    @IBOutlet weak var lblTags: UILabel!
}
