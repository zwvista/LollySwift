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

class PatternsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var vm: PatternsViewModel!
    var arrPatterns: [MPattern] {  sbTextFilter.text != "" ? vm.arrPatternsFiltered! : vm.arrPatterns }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sbTextFilter: UISearchBar!
    @IBOutlet weak var btnScopeFilter: UIButton!
    @IBOutlet weak var btnEdit: UIBarButtonItem!

    let ddScopeFilter = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        ddScopeFilter.anchorView = btnScopeFilter
        ddScopeFilter.dataSource = SettingsViewModel.arrScopePatternFilters
        ddScopeFilter.selectRow(0)
        ddScopeFilter.selectionAction = { [unowned self] (index: Int, item: String) in
            btnScopeFilter.setTitle(item, for: .normal)
            self.searchBarSearchButtonClicked(self.sbTextFilter)
        }
        btnScopeFilter.setTitle(SettingsViewModel.arrScopePatternFilters[0], for: .normal)
        view.showBlurLoader()
        vm = PatternsViewModel(settings: vmSettings, needCopy: false) {
            self.tableView.reloadData()
            self.view.removeBlurLoader()
        }
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        .top
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = arrPatterns[indexPath.row]
        AppDelegate.speak(string: item.PATTERN)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
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
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { _,_ in delete() }
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { _,_ in edit() }
        editAction.backgroundColor = .blue
        let moreAction = UITableViewRowAction(style: .normal, title: "More") { [unowned self] _,_ in
        }

        return [moreAction, deleteAction]
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        applyFilters()
    }
    
    func applyFilters() {
        vm.applyFilters(textFilter: sbTextFilter.text!, scope: btnScopeFilter.titleLabel!.text!)
        tableView.reloadData()
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}

class PatternsCell: UITableViewCell {
    @IBOutlet weak var lblPattern: UILabel!
}
