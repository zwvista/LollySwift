//
//  PhrasesLangViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class PhrasesLangViewController: PhrasesBaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {
    
    var vm: PhrasesLangViewModel!
    var arrPhrases: [MLangPhrase] {
        return searchController.isActive && searchBar.text != "" ? vm.arrPhrasesFiltered! : vm.arrPhrases
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.showBlurLoader()
        vm = PhrasesLangViewModel(settings: AppDelegate.theSettingsViewModel) { [unowned self] in
            self.setupSearchController(delegate: self)
            self.tableView.reloadData()
            self.view.removeBlurLoader()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPhrases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhraseCell", for: indexPath)
        let m = arrPhrases[indexPath.row]
        cell.textLabel!.text = m.PHRASE
        cell.detailTextLabel?.text = m.TRANSLATION
        return cell;
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let m = arrPhrases[indexPath.row]
        phrase = m.PHRASE!
        return indexPath
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        vm.filterPhrasesForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = segue.destination as? PhrasesLangEditViewController {
            controller.vm = vm
        }
    }
}
