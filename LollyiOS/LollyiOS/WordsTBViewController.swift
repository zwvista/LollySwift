//
//  WordsTBViewController.swift
//  LollyiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class WordsTBViewController: WordsBaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {

    var wordsTBViewModel: WordsTBViewModel!
    var arrWords: [MTBWord] {
        return searchController.active && searchBar.text != "" ? wordsTBViewModel.arrWordsFiltered! : wordsTBViewModel.arrWords
    }

    override func viewDidLoad() {
        wordsTBViewModel = WordsTBViewModel(settings: AppDelegate.theSettingsViewModel)
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchBar.delegate = self
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrWords.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WordCell", forIndexPath: indexPath)
        let m = arrWords[indexPath.row]
        cell.textLabel!.text = m.WORD
        cell.detailTextLabel!.text = "\(m.TEXTBOOKNAME!) \(m.UNIT)-\(m.PART)-\(m.SEQNUM)"
        return cell;
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let m = arrWords[indexPath.row]
        word = m.WORD!
        return indexPath
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        wordsTBViewModel.filterWordsForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
        tableView.reloadData()
    }
}