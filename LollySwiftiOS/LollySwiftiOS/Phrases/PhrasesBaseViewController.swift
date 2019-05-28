//
//  PhrasesBaseViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class PhrasesBaseViewController: UITableViewController {
    
    // https://www.raywenderlich.com/113772/uisearchcontroller-tutorial
    let searchController = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar { return searchController.searchBar }
    
    func setupSearchController(delegate: UISearchBarDelegate & UISearchResultsUpdating) {
        // https://stackoverflow.com/questions/28326269/uisearchbar-presented-by-uisearchcontroller-in-table-header-view-animates-too-fa
        searchController.dimsBackgroundDuringPresentation = true
        searchBar.scopeButtonTitles = ["Phrase", "Translation"]
        searchController.searchResultsUpdater = delegate
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        }
        searchBar.delegate = delegate
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        searchBar.placeholder = "Search Phrases"
        searchBar.becomeFirstResponder()
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.isActive = false
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
