//
//  PhrasesUnitsViewController.swift
//  LollyiOS
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class PhrasesUnitsViewController: PhrasesBaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {
    
    var phrasesUnitsViewModel: UnitsPhrasesViewModel!
    var arrPhrases: [MUnitPhrase] {
        return searchController.active && searchBar.text != "" ? phrasesUnitsViewModel.arrPhrasesFiltered! : phrasesUnitsViewModel.arrPhrases
    }
    
    override func viewDidLoad() {
        phrasesUnitsViewModel = UnitsPhrasesViewModel(settings: AppDelegate.theSettingsViewModel)
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchBar.delegate = self
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPhrases.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PhraseCell", forIndexPath: indexPath)
        let m = arrPhrases[indexPath.row]
        cell.textLabel!.text = m.PHRASE
        cell.detailTextLabel?.text = m.TRANSLATION
        return cell;
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let m = arrPhrases[indexPath.row]
        phrase = m.PHRASE!
        return indexPath
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        phrasesUnitsViewModel.filterPhrasesForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
        tableView.reloadData()
    }
}
