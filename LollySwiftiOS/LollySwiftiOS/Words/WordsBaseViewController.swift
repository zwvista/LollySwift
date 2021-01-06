//
//  WordsBaseViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import DropDown

class WordsBaseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sbTextFilter: UISearchBar!
    @IBOutlet weak var btnScopeFilter: UIButton!
    let refreshControl = UIRefreshControl()
    
    let ddScopeFilter = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        ddScopeFilter.anchorView = btnScopeFilter
        ddScopeFilter.dataSource = SettingsViewModel.arrScopeWordFilters
        ddScopeFilter.selectRow(0)
        ddScopeFilter.selectionAction = { [unowned self] (index: Int, item: String) in
            btnScopeFilter.setTitle(item, for: .normal)
            self.searchBarSearchButtonClicked(self.sbTextFilter)
        }
        btnScopeFilter.setTitle(SettingsViewModel.arrScopeWordFilters[0], for: .normal)
        tableView.refreshControl = refreshControl
    }
    
    @IBAction func showScopeFilterDropDown(_ sender: AnyObject) {
        ddScopeFilter.show()
    }

    func itemForRow(row: Int) -> (MWordProtocol & NSObject)? {
        nil
    }

    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath) as! WordsCommonCell
        let item = itemForRow(row: indexPath.row)!
        if cell.lblUnitPartSeqNum != nil {
            cell.lblUnitPartSeqNum.text = (item.value(forKey: "UNITPARTSEQNUM") as! String)
        }
        cell.lblWord.text = item.WORD
        cell.lblNote.text = item.NOTE
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let item = itemForRow(row: indexPath.row)!
        performSegue(withIdentifier: "dict", sender: item)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = itemForRow(row: indexPath.row)!
        if tableView.isEditing {
            performSegue(withIdentifier: "edit", sender: item)
        } else {
            AppDelegate.speak(string: item.WORD)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        applyFilters()
    }

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        applyFilters()
    }
    
    func applyFilters() {
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}

class WordsCommonCell: UITableViewCell {
    @IBOutlet weak var lblUnitPartSeqNum: UILabel!
    @IBOutlet weak var lblWord: UILabel!
    @IBOutlet weak var lblNote: UILabel!
}
