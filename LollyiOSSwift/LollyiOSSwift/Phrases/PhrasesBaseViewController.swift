//
//  PhrasesBaseViewController.swift
//  LollyiOSSwift
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        searchBar.scopeButtonTitles = ["Phrase", "Translation"]
        searchBar.sizeToFit()
        searchBarContainerView.addSubview(searchBar)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}
