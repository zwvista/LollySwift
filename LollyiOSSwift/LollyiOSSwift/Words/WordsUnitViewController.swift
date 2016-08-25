//
//  WordsUnitViewController.swift
//  LollyiOSSwift
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class WordsUnitViewController: WordsBaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {

    var vm: WordsUnitViewModel!
    var arrWords: [MUnitWord] {
        return searchController.active && searchBar.text != "" ? vm.arrWordsFiltered! : vm.arrWords
    }
    
    override func viewDidLoad() {
        vm = WordsUnitViewModel(settings: AppDelegate.theSettingsViewModel)
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
        vm.filterWordsForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if let controller = segue.destinationViewController as? WordsUnitEditViewController {
            controller.vm = vm
        }
    }
}