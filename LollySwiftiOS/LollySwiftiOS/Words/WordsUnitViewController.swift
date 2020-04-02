//
//  WordsUnitViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import RxSwift

class WordsUnitViewController: WordsBaseViewController {

    var vm: WordsUnitViewModel!
    var arrWords: [MUnitWord] {
        return searchController.isActive && searchBar.text != "" ? vm.arrWordsFiltered! : vm.arrWords
    }
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.showBlurLoader()
        vm = WordsUnitViewModel(settings: vmSettings, inTextbook: true, disposeBag: disposeBag, needCopy: false) {
            self.setupSearchController(delegate: self)
            self.tableView.reloadData()
            self.view.removeBlurLoader()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrWords.count
    }
    
    override func itemForRow(row: Int) -> (MWordProtocol & NSObject)? {
        return arrWords[row]
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
        let item = vm.arrWords[i]
        func delete() {
            yesNoAction(title: "delete", message: "Do you really want to delete the word \"\(item.WORD)\"?", yesHandler: { (action) in
                WordsUnitViewModel.delete(item: item).subscribe().disposed(by: self.disposeBag)
                self.vm.arrWords.remove(at: i)
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.reindex()
            }, noHandler: { (action) in
                tableView.reloadRows(at: [indexPath], with: .fade)
            })
        }
        func edit() {
            performSegue(withIdentifier: "edit", sender: item)
        }
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { _,_ in delete() }
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { _,_ in edit() }
        editAction.backgroundColor = .blue
        let moreAction = UITableViewRowAction(style: .normal, title: "More") { [unowned self] _,_ in
            let alertController = UIAlertController(title: "Word", message: item.WORDNOTE, preferredStyle: .alert)
            let deleteAction2 = UIAlertAction(title: "Delete", style: .destructive) { _ in delete() }
            alertController.addAction(deleteAction2)
            let editAction2 = UIAlertAction(title: "Edit", style: .default) { _ in edit() }
            alertController.addAction(editAction2)
            if vmSettings.hasDictNote {
                let noteAction = UIAlertAction(title: "Retrieve Note", style: .default) { _ in
                    self.vm.getNote(index: indexPath.row).subscribe {
                        self.tableView.reloadRows(at: [indexPath], with: .fade)
                    }.disposed(by: self.disposeBag)
                }
                alertController.addAction(noteAction)
            }
            let copyWordAction = UIAlertAction(title: "Copy Word", style: .default) { _ in iOSApi.copyText(item.WORD) }
            alertController.addAction(copyWordAction)
            let googleWordAction = UIAlertAction(title: "Google Word", style: .default) { _ in iOSApi.googleString(item.WORD) }
            alertController.addAction(googleWordAction)
            let openOnlineDictAction = UIAlertAction(title: "Online Dictionary", style: .default) { _ in
                let itemDict = vmSettings.arrDictsReference.first { $0.DICTNAME == vmSettings.selectedDictItem.DICTNAME }!
                let url = itemDict.urlString(word: item.WORD, arrAutoCorrect: vmSettings.arrAutoCorrect)
                UIApplication.shared.openURL(URL(string: url)!)
            }
            alertController.addAction(openOnlineDictAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true) {}
        }

        return [moreAction, deleteAction]
    }
    
    override func applyFilters() {
        vm.applyFilters(textFilter: searchBar.text!, scope: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex], levelge0only: false, textbookFilter: 0)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? WordsUnitDetailViewController {
            controller.vm = vm
            controller.item = sender as? MUnitWord ?? vm.newUnitWord()
        } else if let controller = segue.destination as? WordsDictViewController {
            controller.vm.arrWords = arrWords.map { $0.WORD }
            controller.vm.currentWordIndex = vm.arrWords.indexes(of: sender as! MUnitWord)[0]
        } else if let controller = (segue.destination as? UINavigationController)?.topViewController as? WordsUnitBatchViewController {
            controller.vm = vm
        }
    }
    
    @IBAction func btnEditClicked(_ sender: AnyObject) {
        tableView.isEditing = !tableView.isEditing
        btnEdit.title = tableView.isEditing ? "Done" : "Edit"
    }
    
    @IBAction func btnMoreClicked(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Words", message: "More", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in self.performSegue(withIdentifier: "add", sender: self) }
        alertController.addAction(addAction)
        
        func startTimer(ifEmpty: Bool) {
            self.view.showBlurLoader()
            vm.getNotes(ifEmpty: ifEmpty, oneComplete: { _ in }, allComplete: {
                // https://stackoverflow.com/questions/28302019/getting-a-this-application-is-modifying-the-autolayout-engine-from-a-background
                DispatchQueue.main.async {
                    self.view.removeBlurLoader()
                    self.tableView.reloadData()
                }
            })
        }

        if vmSettings.hasDictNote {
            let notesAllAction = UIAlertAction(title: "Retrieve All Notes", style: .default) { _ in
                startTimer(ifEmpty: false)
            }
            alertController.addAction(notesAllAction)
            let notesEmptyAction = UIAlertAction(title: "Retrieve Notes If Empty", style: .default) { _ in
                startTimer(ifEmpty: true)
            }
            alertController.addAction(notesEmptyAction)
        }
        let batchAction = UIAlertAction(title: "Batch Edit", style: .default) { _ in
            self.performSegue(withIdentifier: "batch", sender: nil)
        }
        alertController.addAction(batchAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true) {}
    }

    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "Done" else {return}
        if let controller = segue.source as? WordsUnitDetailViewController {
            controller.onDone()
            tableView.reloadData()
            if controller.isAdd && !controller.item.WORD.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.performSegue(withIdentifier: "add", sender: self)
                }
            }
        } else if let controller = segue.source as? WordsUnitBatchViewController {
            controller.onDone()
            tableView.reloadData()
        }
    }
}
