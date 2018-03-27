//
//  WordsLangViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class WordsLangViewController: WordsBaseViewController, UISearchBarDelegate, UISearchResultsUpdating {

    var vm: WordsLangViewModel!
    var arrWords: [MLangWord] {
        return searchController.isActive && searchBar.text != "" ? vm.arrWordsFiltered! : vm.arrWords
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.showBlurLoader()
        vm = WordsLangViewModel(settings: AppDelegate.theSettingsViewModel) { [unowned self] in
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
        cell.textLabel!.text = m.WORD
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let i = indexPath.row
            WordsLangViewModel.delete(self.vm.arrWords[i].ID) {}
            self.vm.arrWords.remove(at: i)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        }
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            let m = self.arrWords[indexPath.row]
            self.performSegue(withIdentifier: "edit", sender: m)
        }
        editAction.backgroundColor = .blue
        
        return [editAction, deleteAction]
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? WordsLangDetailViewController {
            controller.mWord = sender is MLangWord ? sender as! MLangWord : MLangWord()
        }
    }
}
