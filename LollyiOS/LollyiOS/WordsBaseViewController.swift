//
//  WordsBaseViewController.swift
//  LollyiOS
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class WordsBaseViewController: UIViewController {

    // https://www.raywenderlich.com/113772/uisearchcontroller-tutorial
    let searchController = UISearchController(searchResultsController: nil)
    var word = ""
    
    @IBOutlet weak var tableView: UITableView!
    // http://stackoverflow.com/questions/26417591/uisearchcontroller-in-a-uiviewcontroller
    @IBOutlet weak var searchBarContainerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = ["Word", "Translation"]
        searchController.searchBar.sizeToFit()
        searchBarContainerView.addSubview(searchController.searchBar)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as! WordsDetailViewController
        controller.word = word
    }
}
