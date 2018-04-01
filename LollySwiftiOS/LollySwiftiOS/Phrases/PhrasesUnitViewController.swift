//
//  PhrasesUnitsViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class PhrasesUnitViewController: PhrasesBaseViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    var vm: PhrasesUnitViewModel!
    var arrPhrases: [MUnitPhrase] {
        return searchController.isActive && searchBar.text != "" ? vm.arrPhrasesFiltered! : vm.arrPhrases
    }
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.showBlurLoader()
        vm = PhrasesUnitViewModel(settings: vmSettings) { [unowned self] in
            self.setupSearchController(delegate: self)
            self.tableView.reloadData()
            self.view.removeBlurLoader()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPhrases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhraseCell", for: indexPath) as! PhrasesUnitCell
        let m = arrPhrases[indexPath.row]
        cell.lblUnitPartSeqNum!.text = m.UNITPARTSEQNUM
        cell.lblPhrase!.text = m.PHRASE
        cell.lblTranslation!.text = m.TRANSLATION
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return vmSettings.isSingleUnitPart
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let m = vm.arrPhrases[(sourceIndexPath as NSIndexPath).row]
        vm.arrPhrases.remove(at: (sourceIndexPath as NSIndexPath).row)
        vm.arrPhrases.insert(m, at: (destinationIndexPath as NSIndexPath).row)
        tableView.beginUpdates()
        vm.reindex {
            tableView.reloadRows(at: [IndexPath(row: $0, section: 0)], with: .fade)
        }
        tableView.endUpdates()
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let i = indexPath.row
            let m = self.vm.arrPhrases[i]
            self.yesNoAction(title: "delete", message: "Do you really want to delete the phrase \"\(m.PHRASE)\"?", yesHandler: { (action) in
                PhrasesUnitViewModel.delete(m.ID) {}
                self.vm.arrPhrases.remove(at: i)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }, noHandler: { (action) in
                tableView.reloadRows(at: [indexPath], with: .fade)
            })
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            let m = self.arrPhrases[indexPath.row]
            self.performSegue(withIdentifier: "edit", sender: m)
        }
        editAction.backgroundColor = .blue
        
        return [editAction, deleteAction]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let m = arrPhrases[indexPath.row]
        performSegue(withIdentifier: "edit", sender: m)
    }

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        vm.filterPhrasesForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let controller = (segue.destination as? UINavigationController)?.topViewController as? PhrasesUnitDetailViewController else {return}
        controller.vm = vm
        controller.mPhrase = sender as? MUnitPhrase ?? vm.newUnitPhrase()
    }
    
    @IBAction func btnEditClicked(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
        btnEdit.title = tableView.isEditing ? "Done" : "Edit"
    }
    
    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "Done" else {return}
        let controller = segue.source as! PhrasesUnitDetailViewController
        controller.onDone()
    }
}

class PhrasesUnitCell: UITableViewCell {
    @IBOutlet weak var lblPhrase: UILabel!
    @IBOutlet weak var lblTranslation: UILabel!
    @IBOutlet weak var lblUnitPartSeqNum: UILabel!
}
