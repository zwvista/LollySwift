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
    var arrWords: [MUnitWord] {
        return searchController.active && searchBar.text != "" ? wordsUnitsViewModel.arrWordsFiltered! : wordsUnitsViewModel.arrWords
    }
    
    override func viewDidLoad() {
        wordsUnitsViewModel = WordsUnitsViewModel(settings: AppDelegate.theSettingsViewModel)
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
        cell.detailTextLabel!.text = "\(m.UNIT)-\(m.PART)-\(m.SEQNUM)"
        return cell;
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let m = arrWords[indexPath.row]
        word = m.WORD!
        return indexPath
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            wordsUnitsViewModel.arrWords.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let obj = wordsUnitsViewModel.arrWords[sourceIndexPath.row]
        wordsUnitsViewModel.arrWords.removeAtIndex(sourceIndexPath.row)
        wordsUnitsViewModel.arrWords.insert(obj, atIndex: destinationIndexPath.row)
    }

    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    }

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        wordsUnitsViewModel.filterWordsForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
        tableView.reloadData()
    }
}