//
//  PhrasesLangViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import RxSwift

class PhrasesLangViewController: PhrasesBaseViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    var vm: PhrasesLangViewModel!
    var arrPhrases: [MLangPhrase] {
        return searchController.isActive && searchBar.text != "" ? vm.arrPhrasesFiltered! : vm.arrPhrases
    }
    
    let disposeBag = DisposeBag()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.showBlurLoader()
        vm = PhrasesLangViewModel(settings: vmSettings, disposeBag: disposeBag) {
            self.setupSearchController(delegate: self)
            self.tableView.reloadData()
            self.view.removeBlurLoader()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPhrases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhraseCell", for: indexPath)
        let item = arrPhrases[indexPath.row]
        cell.textLabel!.text = item.PHRASE
        cell.detailTextLabel?.text = item.TRANSLATION
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let i = indexPath.row
            let item = self.vm.arrPhrases[i]
            self.yesNoAction(title: "delete", message: "Do you really want to delete the phrase \"\(item.PHRASE)\"?", yesHandler: { (action) in
                PhrasesLangViewModel.delete(item.ID).subscribe().disposed(by: self.disposeBag)
                self.vm.arrPhrases.remove(at: i)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }, noHandler: { (action) in
                tableView.reloadRows(at: [indexPath], with: .fade)
            })
        }
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            let item = self.arrPhrases[indexPath.row]
            self.performSegue(withIdentifier: "edit", sender: item)
        }
        editAction.backgroundColor = .blue
        
        return [editAction, deleteAction]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = arrPhrases[indexPath.row]
        performSegue(withIdentifier: "edit", sender: item)
    }

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        vm.filterPhrasesForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? PhrasesLangDetailViewController {
            controller.vm = vm
            controller.mPhrase = sender as? MLangPhrase ?? MLangPhrase()
        }
    }
    
    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "Done" else {return}
        let controller = segue.source as! PhrasesLangDetailViewController
        controller.onDone()
    }
}
