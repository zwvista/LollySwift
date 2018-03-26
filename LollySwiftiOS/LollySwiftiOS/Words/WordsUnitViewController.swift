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
        vm = WordsUnitViewModel(settings: AppDelegate.theSettingsViewModel) {
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
        let m = arrWords[(indexPath as NSIndexPath).row]
        cell.textLabel!.text = m.description
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
        for i in 1...vm.arrWords.count {
            let m = vm.arrWords[i - 1]
            guard m.SEQNUM != i else {continue}
            m.SEQNUM = i
            WordsUnitViewModel.update(m.ID, seqnum: m.SEQNUM) {}
        }
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let i = (indexPath as NSIndexPath).row
            WordsUnitViewModel.delete(self.vm.arrWords[i].ID) {}
            self.vm.arrWords.remove(at: i)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        }
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            self.performSegue(withIdentifier: "edit", sender: self)
        }
        editAction.backgroundColor = .blue
        
        return [editAction, deleteAction]
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        word = arrWords[(indexPath as NSIndexPath).row].WORD
        performSegue(withIdentifier: isEditing ? "edit" : "dict", sender: self)
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
        if !(sender is UIBarButtonItem) {
            controller.mWord = vm.arrWords[(tableView.indexPathForSelectedRow! as NSIndexPath).row]
        } else {
            let o = MUnitWord()
            o.TEXTBOOKID = vmSettings.USTEXTBOOKID
            let maxElem = vm.arrWords.max{ (o1, o2) in (o1.UNITPART, o1.SEQNUM) < (o2.UNITPART, o2.SEQNUM) }
            o.UNIT = maxElem?.UNIT ?? vmSettings.USUNITTO
            o.PART = maxElem?.PART ?? vmSettings.USPARTTO
            o.SEQNUM = (maxElem?.SEQNUM ?? 0) + 1
            controller.mWord = o
        }
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
