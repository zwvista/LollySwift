//
//  WordsUnitViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class WordsUnitViewController: WordsBaseViewController, UISearchBarDelegate, UISearchResultsUpdating {

    var vm: WordsUnitViewModel!
    var arrWords: [MUnitWord] {
        return searchController.isActive && searchBar.text != "" ? vm.arrWordsFiltered! : vm.arrWords
    }
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.showBlurLoader()
        vm = WordsUnitViewModel(settings: vmSettings) {
            self.setupSearchController(delegate: self)
            self.tableView.reloadData()
            self.view.removeBlurLoader()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath) as! WordsUnitCell
        let m = arrWords[indexPath.row]
        cell.lblWordNote!.text = m.WORDNOTE
        cell.lblUnitPartSeqNum!.text = m.UNITPARTSEQNUM(arrParts: vmSettings.arrParts)
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return vmSettings.isSingleUnitPart
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let m = vm.arrWords[(sourceIndexPath as NSIndexPath).row]
        vm.arrWords.remove(at: (sourceIndexPath as NSIndexPath).row)
        vm.arrWords.insert(m, at: (destinationIndexPath as NSIndexPath).row)
        tableView.beginUpdates()
        vm.reindex {
            tableView.reloadRows(at: [IndexPath(row: $0, section: 0)], with: .fade)
        }
        tableView.endUpdates()
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let i = indexPath.row
            let m = self.vm.arrWords[i]
            self.yesNoAction(title: "delete", message: "Do you really want to delete the word \"\(m.WORD)\"?", yesHandler: { (action) in
                WordsUnitViewModel.delete(m.ID) {}
                self.vm.arrWords.remove(at: i)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }, noHandler: { (action) in
                tableView.reloadRows(at: [indexPath], with: .fade)
            })
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
        if tableView.isEditing {
            performSegue(withIdentifier: "edit", sender: m)
        } else {
            performSegue(withIdentifier: "dict", sender: m.WORD)
        }
    }

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        vm.filterWordsForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let controller = (segue.destination as? UINavigationController)?.topViewController as? WordsUnitDetailViewController else {return}
        controller.vm = vm
        controller.mWord = sender as? MUnitWord ?? vm.newUnitWord()
    }
    
    @IBAction func btnEditClicked(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
        btnEdit.title = tableView.isEditing ? "Done" : "Edit"
    }
    
    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "Done" else {return}
        let controller = segue.source as! WordsUnitDetailViewController
        controller.onDone()
    }
}

class WordsUnitCell: UITableViewCell {
    @IBOutlet weak var lblWordNote: UILabel!
    @IBOutlet weak var lblUnitPartSeqNum: UILabel!
}
