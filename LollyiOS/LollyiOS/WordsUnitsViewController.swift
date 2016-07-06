//
//  WordsUnitsViewController.swift
//  LollyiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class WordsUnitsViewController: WordsBaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {

    var wordsUnitsViewModel: WordsUnitsViewModel!
    
    override func viewDidLoad() {
        wordsUnitsViewModel = WordsUnitsViewModel(settings: AppDelegate.theSettingsViewModel)
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordsUnitsViewModel.arrWords.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WordCell", forIndexPath: indexPath)
        let m = wordsUnitsViewModel.arrWords[indexPath.row]
        cell.textLabel!.text = m.WORD
        return cell;
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let m = wordsUnitsViewModel.arrWords[indexPath.row]
        word = m.WORD!
        return indexPath
    }

    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    }

    func updateSearchResultsForSearchController(searchController: UISearchController) {
    }
}