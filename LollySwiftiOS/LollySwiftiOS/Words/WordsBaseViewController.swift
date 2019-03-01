//
//  WordsBaseViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class WordsBaseViewController: UITableViewController {

    // https://www.raywenderlich.com/113772/uisearchcontroller-tutorial
    let searchController = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar { return searchController.searchBar }
    
    func setupSearchController(delegate: UISearchBarDelegate & UISearchResultsUpdating) {
        // https://stackoverflow.com/questions/28326269/uisearchbar-presented-by-uisearchcontroller-in-table-header-view-animates-too-fa
        searchController.dimsBackgroundDuringPresentation = true
        searchBar.scopeButtonTitles = ["Word", "Note"]
        searchController.searchResultsUpdater = delegate
        searchBar.delegate = delegate
        tableView.tableHeaderView = searchBar
        definesPresentationContext = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.isActive = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
