//
//  PhrasesBaseViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import DropDown

class PhrasesBaseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sbTextFilter: UISearchBar!
    @IBOutlet weak var btnScopeFilter: UIButton!
    let refreshControl = UIRefreshControl()

    let ddScopeFilter = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        ddScopeFilter.anchorView = btnScopeFilter
        ddScopeFilter.dataSource = SettingsViewModel.arrScopePhraseFilters
        ddScopeFilter.selectRow(0)
        ddScopeFilter.selectionAction = { [unowned self] (index: Int, item: String) in
            btnScopeFilter.setTitle(item, for: .normal)
            self.searchBarSearchButtonClicked(self.sbTextFilter)
        }
        btnScopeFilter.setTitle(SettingsViewModel.arrScopePhraseFilters[0], for: .normal)
        tableView.refreshControl = refreshControl
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        .top
    }
    
    @IBAction func showScopeFilterDropDown(_ sender: AnyObject) {
        ddScopeFilter.show()
    }

    func itemForRow(row: Int) -> (MPhraseProtocol & NSObject)? {
        nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhraseCell", for: indexPath) as! PhrasesCommonCell
        let item = itemForRow(row: indexPath.row)!
        if cell.lblUnitPartSeqNum != nil {
            cell.lblUnitPartSeqNum.text = (item.value(forKey: "UNITPARTSEQNUM") as! String)
        }
        cell.lblPhrase!.text = item.PHRASE
        cell.lblTranslation!.text = item.TRANSLATION
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = itemForRow(row: indexPath.row)!
        if tableView.isEditing {
            performSegue(withIdentifier: "edit", sender: item)
        } else {
            AppDelegate.speak(string: item.PHRASE)
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

class PhrasesCommonCell: UITableViewCell {
    @IBOutlet weak var lblUnitPartSeqNum: UILabel!
    @IBOutlet weak var lblPhrase: UILabel!
    @IBOutlet weak var lblTranslation: UILabel!
}
