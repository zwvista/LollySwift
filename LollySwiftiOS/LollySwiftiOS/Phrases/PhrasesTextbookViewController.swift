//
//  PhrasesTextbookViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import RxSwift

class PhrasesTextbookViewController: PhrasesBaseViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    var vm: PhrasesUnitViewModel!
    var arrPhrases: [MUnitPhrase] {
        return searchController.isActive && searchBar.text != "" ? vm.arrPhrasesFiltered! : vm.arrPhrases
    }
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.showBlurLoader()
        vm = PhrasesUnitViewModel(settings: vmSettings, disposeBag: disposeBag) {
            self.setupSearchController(delegate: self)
            self.tableView.reloadData()
            self.view.removeBlurLoader()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPhrases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhraseCell", for: indexPath) as! PhrasesTextbookCell
        let item = arrPhrases[indexPath.row]
        cell.lblUnitPartSeqNum!.text = item.UNITPARTSEQNUM(arrParts: vmSettings.arrParts)
        cell.lblPhrase!.text = item.PHRASE
        cell.lblTranslation!.text = item.TRANSLATION
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return vmSettings.isSingleUnitPart
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = vm.arrPhrases[(sourceIndexPath as NSIndexPath).row]
        vm.arrPhrases.remove(at: (sourceIndexPath as NSIndexPath).row)
        vm.arrPhrases.insert(item, at: (destinationIndexPath as NSIndexPath).row)
        tableView.beginUpdates()
        vm.reindex {
            tableView.reloadRows(at: [IndexPath(row: $0, section: 0)], with: .fade)
        }
        tableView.endUpdates()
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let i = indexPath.row
        let item = self.vm.arrPhrases[i]
        func delete() {
            self.yesNoAction(title: "delete", message: "Do you really want to delete the phrase \"\(item.PHRASE)\"?", yesHandler: { (action) in
                PhrasesUnitViewModel.delete(item.ID).subscribe().disposed(by: self.disposeBag)
                self.vm.arrPhrases.remove(at: i)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }, noHandler: { (action) in
                tableView.reloadRows(at: [indexPath], with: .fade)
            })
        }
        func edit() {
            self.performSegue(withIdentifier: "edit", sender: item)
        }
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { _,_ in delete() }
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { _,_ in edit() }
        editAction.backgroundColor = .blue
        let moreAction = UITableViewRowAction(style: .normal, title: "More") { [unowned self] _,_ in
            let alertController = UIAlertController(title: "Word", message: item.PHRASE, preferredStyle: .alert)
            let deleteAction2 = UIAlertAction(title: "Delete", style: .destructive) { _ in delete() }
            alertController.addAction(deleteAction2)
            let editAction2 = UIAlertAction(title: "Edit", style: .default) { _ in edit() }
            alertController.addAction(editAction2)
            let copyPhraseAction = UIAlertAction(title: "Copy Phrase", style: .default) { _ in iOSApi.copyText(item.PHRASE) }
            alertController.addAction(copyPhraseAction)
            let googlePhraseAction = UIAlertAction(title: "Google Phrase", style: .default) { _ in iOSApi.googleString(item.PHRASE) }
            alertController.addAction(googlePhraseAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true) {}
        }

        return [moreAction, deleteAction]
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
        tableView.reloadData()
        if controller.isAdd {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.performSegue(withIdentifier: "add", sender: self)
            }
        }
    }
}

class PhrasesTextbookCell: UITableViewCell {
    @IBOutlet weak var lblPhrase: UILabel!
    @IBOutlet weak var lblTranslation: UILabel!
    @IBOutlet weak var lblUnitPartSeqNum: UILabel!
}
