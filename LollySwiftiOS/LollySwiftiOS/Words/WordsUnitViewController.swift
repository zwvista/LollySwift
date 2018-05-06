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
    var timer = Timer()
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let item = arrWords[indexPath.row]
        cell.lblWordNote!.text = item.WORDNOTE
        cell.lblUnitPartSeqNum!.text = item.UNITPARTSEQNUM(arrParts: vmSettings.arrParts)
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return vmSettings.isSingleUnitPart
    }
    
    private func reindex() {
        tableView.beginUpdates()
        vm.reindex {
            self.tableView.reloadRows(at: [IndexPath(row: $0, section: 0)], with: .fade)
        }
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        vm.moveWord(at: sourceIndexPath.row, to: destinationIndexPath.row)
        reindex()
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let i = indexPath.row
        let item = self.vm.arrWords[i]
        func delete() {
            self.yesNoAction(title: "delete", message: "Do you really want to delete the word \"\(item.WORD)\"?", yesHandler: { (action) in
                WordsUnitViewModel.delete(item.ID).subscribe()
                self.vm.arrWords.remove(at: i)
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.reindex()
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
        let moreAction = UITableViewRowAction(style: .normal, title: "More") { _,_ in
            let alertController = UIAlertController(title: "Word", message: item.WORDNOTE, preferredStyle: .alert)
            let deleteAction2 = UIAlertAction(title: "Delete", style: .destructive) { _ in delete() }
            alertController.addAction(deleteAction2)
            let editAction2 = UIAlertAction(title: "Edit", style: .default) { _ in edit() }
            alertController.addAction(editAction2)
            if self.vm.mDictNote != nil {
                let noteAction = UIAlertAction(title: "Retrieve Note", style: .default) { _ in
                    self.vm.getNote(index: indexPath.row) {
                        self.tableView.reloadRows(at: [indexPath], with: .fade)
                    }
                }
                alertController.addAction(noteAction)
            }
            let copyWordAction = UIAlertAction(title: "Copy Word", style: .default) { _ in UIPasteboard.general.string = item.WORD }
            alertController.addAction(copyWordAction)
            let googleWordAction = UIAlertAction(title: "Google Word", style: .default) { _ in UIApplication.shared.openURL(URL(string: "https://www.google.com/search?q=\(item.WORD)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!) }
            alertController.addAction(googleWordAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true) {}
        }

        return [moreAction, deleteAction]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = arrWords[indexPath.row]
        if tableView.isEditing {
            performSegue(withIdentifier: "edit", sender: item)
        } else {
            performSegue(withIdentifier: "dict", sender: item.WORD)
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
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? WordsUnitDetailViewController {
            controller.vm = vm
            controller.mWord = sender as? MUnitWord ?? vm.newUnitWord()
        } else if let controller = segue.destination as? WordsDictViewController {
            controller.vm.arrWords = arrWords.map { $0.WORD }
            controller.vm.selectWordIndex = tableView.indexPathForSelectedRow!.row
        }
    }
    
    @IBAction func btnEditClicked(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
        btnEdit.title = tableView.isEditing ? "Done" : "Edit"
    }
    
    @IBAction func btnMoreClicked(_ sender: Any) {
        let alertController = UIAlertController(title: "Words", message: "More", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in self.performSegue(withIdentifier: "add", sender: self) }
        alertController.addAction(addAction)
        if vm.mDictNote != nil {
            let notesAllAction = UIAlertAction(title: "Retrieve All Notes", style: .default) { _ in
                self.startTimer(ifEmpty: false)
            }
            alertController.addAction(notesAllAction)
            let notesEmptyAction = UIAlertAction(title: "Retrieve Notes If Empty", style: .default) { _ in
                self.startTimer(ifEmpty: true)
            }
            alertController.addAction(notesEmptyAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true) {}
    }

    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "Done" else {return}
        let controller = segue.source as! WordsUnitDetailViewController
        controller.onDone()
        tableView.reloadData()
        if controller.isAdd {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.performSegue(withIdentifier: "add", sender: self)
            }
        }
    }

    func startTimer(ifEmpty: Bool) {
        vm.getNotes(ifEmpty: ifEmpty) {
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(Double($0) / 1000.0), target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
            self.view.showBlurLoader()
        }
    }
    
    @objc
    func timerAction() {
        vm.getNextNote(rowComplete: { _ in }, allComplete: {
            self.timer.invalidate()
            self.view.removeBlurLoader()
            self.tableView.reloadData()
        })
    }
}

class WordsUnitCell: UITableViewCell {
    @IBOutlet weak var lblWordNote: UILabel!
    @IBOutlet weak var lblUnitPartSeqNum: UILabel!
}
