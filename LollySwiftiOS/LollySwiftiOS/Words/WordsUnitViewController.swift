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
    var mNoteSite = vmSettings.selectedNoteSite
    var timer = Timer()
    var noteFromIndex = 0, noteToIndex = 0, noteIfEmpty = true
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
        let m = self.vm.arrWords[i]
        func delete() {
            self.yesNoAction(title: "delete", message: "Do you really want to delete the word \"\(m.WORD)\"?", yesHandler: { (action) in
                WordsUnitViewModel.delete(m.ID) {}
                self.vm.arrWords.remove(at: i)
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.reindex()
            }, noHandler: { (action) in
                tableView.reloadRows(at: [indexPath], with: .fade)
            })
        }
        func edit() {
            self.performSegue(withIdentifier: "edit", sender: m)
        }
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { _,_ in delete() }
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { _,_ in edit() }
        editAction.backgroundColor = .blue
        let moreAction = UITableViewRowAction(style: .normal, title: "More") { _,_ in
            let alertController = UIAlertController(title: "Word", message: m.WORD, preferredStyle: .alert)
            let deleteAction2 = UIAlertAction(title: "Delete", style: .destructive) { _ in delete() }
            let editAction2 = UIAlertAction(title: "Edit", style: .default) { _ in edit() }
            let noteAction = UIAlertAction(title: "Retrieve Note", style: .default) { _ in self.getNote(indexPath: indexPath) }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
            
            alertController.addAction(deleteAction2)
            alertController.addAction(editAction2)
            alertController.addAction(noteAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true) {}
        }

        return [moreAction, deleteAction]
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
    
    @IBAction func btnMoreClicked(_ sender: Any) {
        let alertController = UIAlertController(title: "Words", message: "More", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in self.performSegue(withIdentifier: "add", sender: self) }
        let notesAllAction = UIAlertAction(title: "Retrieve All Notes", style: .default) { _ in
            self.startTimer(from: 0, to: self.vm.arrWords.count, nonEmpty: false)
        }
        let notesEmptyAction = UIAlertAction(title: "Retrieve Notes If Empty", style: .default) { _ in
            self.startTimer(from: 0, to: self.vm.arrWords.count, nonEmpty: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        
        alertController.addAction(addAction)
        alertController.addAction(notesAllAction)
        alertController.addAction(notesEmptyAction)
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
    
    func getNote(indexPath: IndexPath) {
        let m = self.vm.arrWords[indexPath.row]
        let url = mNoteSite.urlString(m.WORD)
        RestApi.getHtml(url: url) { html in
//            print(html)
            m.NOTE = self.mNoteSite.htmlNote(html)
            WordsUnitViewModel.update(m.ID, note: m.NOTE!) {
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
    }

    func startTimer(from: Int, to: Int, nonEmpty: Bool) {
        noteFromIndex = from; noteToIndex = to; noteIfEmpty = nonEmpty
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(Double(mNoteSite.WAIT!) / 1000.0), target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        self.view.showBlurLoader()
    }
    
    @objc func timerAction() {
        if noteIfEmpty {
            while noteFromIndex < noteToIndex && !vm.arrWords[noteFromIndex].NOTE!.isEmpty {
                noteFromIndex += 1
            }
        }
        if noteFromIndex >= noteToIndex {
            timer.invalidate()
            self.view.removeBlurLoader()
        } else {
            getNote(indexPath: IndexPath(row: noteFromIndex, section: 0))
            noteFromIndex += 1
        }
    }
}

class WordsUnitCell: UITableViewCell {
    @IBOutlet weak var lblWordNote: UILabel!
    @IBOutlet weak var lblUnitPartSeqNum: UILabel!
}
