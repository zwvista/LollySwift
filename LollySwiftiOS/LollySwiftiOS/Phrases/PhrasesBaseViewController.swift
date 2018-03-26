//
//  PhrasesBaseViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class PhrasesBaseViewController: UIViewController {
    
    // https://www.raywenderlich.com/113772/uisearchcontroller-tutorial
    let searchController = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar { return searchController.searchBar }
    var phrase = ""
    
    @IBOutlet weak var tableView: UITableView!
    // http://stackoverflow.com/questions/26417591/uisearchcontroller-in-a-uiviewcontroller
    @IBOutlet weak var searchBarContainerView: UIView!
    
    func setupSearchController(delegate: UISearchBarDelegate & UISearchResultsUpdating) {
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        searchBar.scopeButtonTitles = ["Phrase", "Translation"]
        searchBar.sizeToFit()
        searchBarContainerView.addSubview(searchBar)
        searchController.searchResultsUpdater = delegate
        searchBar.delegate = delegate
        // https://stackoverflow.com/questions/6466893/uisearchbar-width-wrong-in-landscape
        searchBar.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.isActive = false
    }
}
