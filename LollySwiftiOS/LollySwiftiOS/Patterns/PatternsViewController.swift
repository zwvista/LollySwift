//
//  PatternsViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2020/11/05.
//  Copyright © 2020 趙 偉. All rights reserved.
//

import UIKit
import DropDown
import RxSwift
import NSObject_Rx
import RxBinding

class PatternsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var vm: PatternsViewModel!
    var arrPatterns: [MPattern] {  sbTextFilter.text != "" ? vm.arrPatternsFiltered! : vm.arrPatterns }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sbTextFilter: UISearchBar!
    @IBOutlet weak var btnScopeFilter: UIButton!
    let refreshControl = UIRefreshControl()

    let ddScopeFilter = DropDown()
    
    func applyFilters() {
        vm.applyFilters()
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ddScopeFilter.anchorView = btnScopeFilter
        ddScopeFilter.dataSource = SettingsViewModel.arrScopePatternFilters
        ddScopeFilter.selectRow(0)
        ddScopeFilter.selectionAction = { [unowned self] (index: Int, item: String) in
            vm.scopeFilter.accept(item)
        }
        btnScopeFilter.setTitle(SettingsViewModel.arrScopePatternFilters[0], for: .normal)
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        refresh(refreshControl)
        _ = vm.textFilter <~> sbTextFilter.searchTextField.rx.textInput
        _ = vm.scopeFilter ~> btnScopeFilter.rx.title(for: .normal)
        vm.textFilter.subscribe(onNext: { [unowned self] _ in
            self.applyFilters()
        }) ~ rx.disposeBag
        vm.scopeFilter.subscribe(onNext: { [unowned self] _ in
            self.applyFilters()
        }) ~ rx.disposeBag
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        view.showBlurLoader()
        vm = PatternsViewModel(settings: vmSettings, needCopy: false) {
            sender.endRefreshing()
            self.tableView.reloadData()
            self.view.removeBlurLoader()
        }
    }
    
    @IBAction func showScopeFilterDropDown(_ sender: AnyObject) {
        ddScopeFilter.show()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrPatterns.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatternCell", for: indexPath) as! PatternsCell
        let item = arrPatterns[indexPath.row]
        cell.lblPattern.text = item.PATTERN
        cell.lblTags.text = item.TAGS
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        vm.selectedPatternItem = arrPatterns[indexPath.row]
        AppDelegate.speak(string: vm.selectedPatternItem!.PATTERN)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let i = indexPath.row
        let item = vm.arrPatterns[i]
        func delete() {
            yesNoAction(title: "delete", message: "Do you really want to delete the pattern \"\(item.PATTERN)\"?", yesHandler: { (action) in
                PatternsViewModel.delete(item.ID).subscribe() ~ self.rx.disposeBag
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
            let browseWebPagesAction = UIAlertAction(title: "Browse Web Pages", style: .default) { _ in performSegue(withIdentifier: "browse pages", sender: item) }
            alertController.addAction(browseWebPagesAction)
            let editWebPagesAction = UIAlertAction(title: "Edit Web Pages", style: .default) { _ in performSegue(withIdentifier: "edit pages", sender: item) }
            alertController.addAction(editWebPagesAction)
            let copyPatternAction = UIAlertAction(title: "Copy Pattern", style: .default) { _ in iOSApi.copyText(item.PATTERN) }
            alertController.addAction(copyPatternAction)
            let googlePatternAction = UIAlertAction(title: "Google Pattern", style: .default) { _ in iOSApi.googleString(item.PATTERN) }
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
            controller.startEdit(vm: vm, item: item)
        } else if let controller = segue.destination as? PatternsWebPagesBrowseViewController {
            vm.selectedPatternItem = sender as? MPattern
            controller.vm = PatternsWebPagesViewModel(settings: vmSettings, needCopy: false)
            controller.vm.selectedPatternItem = vm.selectedPatternItem
        } else if let controller = segue.destination as? PatternsWebPagesListViewController {
            vm.selectedPatternItem = sender as? MPattern
            controller.vm = PatternsWebPagesViewModel(settings: vmSettings, needCopy: false)
            controller.vm.selectedPatternItem = vm.selectedPatternItem
        }
    }

    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "Done" else {return}
        if let controller = segue.source as? PatternsDetailViewController {
            controller.vmEdit.onOK().subscribe {
                self.tableView.reloadData()
                if controller.vmEdit.isAdd {
                    self.performSegue(withIdentifier: "add", sender: self)
                }
            }) ~ rx.disposeBag
        }
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}

class PatternsCell: UITableViewCell {
    @IBOutlet weak var lblPattern: UILabel!
    @IBOutlet weak var lblTags: UILabel!
}
