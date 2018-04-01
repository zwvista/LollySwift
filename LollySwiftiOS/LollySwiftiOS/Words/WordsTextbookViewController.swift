//
//  WordsTextbookViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class WordsTextbookViewController: WordsBaseViewController, UISearchBarDelegate, UISearchResultsUpdating {

    var vm: WordsTextbookViewModel!
    var arrWords: [MTextbookWord] {
        return searchController.isActive && searchBar.text != "" ? vm.arrWordsFiltered! : vm.arrWords
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.showBlurLoader()
        vm = WordsTextbookViewModel(settings: vmSettings) {
            self.setupSearchController(delegate: self)
            self.tableView.reloadData()
            self.view.removeBlurLoader()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath)
        let m = arrWords[indexPath.row]
        cell.textLabel!.text = m.description
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let m = arrWords[indexPath.row]
        performSegue(withIdentifier: "dict", sender: m.WORD)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        vm.filterWordsForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
        tableView.reloadData()
    }
}
