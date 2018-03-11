//
//  WordsBaseViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class WordsBaseViewController: UIViewController {

    // https://www.raywenderlich.com/113772/uisearchcontroller-tutorial
    let searchController = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar { return searchController.searchBar }
    var word = ""
    
    @IBOutlet weak var tableView: UITableView!
    // http://stackoverflow.com/questions/26417591/uisearchcontroller-in-a-uiviewcontroller
    @IBOutlet weak var searchBarContainerView: UIView!

    func setupSearchController(delegate: UISearchBarDelegate & UISearchResultsUpdating) {
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        searchBar.scopeButtonTitles = ["Word", "Translation"]
        searchBar.sizeToFit()
        searchBarContainerView.addSubview(searchBar)
        searchController.searchResultsUpdater = delegate
        searchBar.delegate = delegate
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? WordsDictViewController {
            controller.word = word
        }
    }
}
