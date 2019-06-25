//
//  WordsUnitViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import RxSwift
import AVFoundation

class WordsUnitViewController: WordsBaseViewController, UISearchBarDelegate, UISearchResultsUpdating, UIGestureRecognizerDelegate {

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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath) as! WordsCommonCell
        let item = arrWords[indexPath.row]
        cell.lblUnitPartSeqNum.text = item.UNITPARTSEQNUM
        cell.lblWord.text = item.WORD
        cell.lblNote.text = item.NOTE
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGestureRecognizer.delegate = self
        cell.lblWord.addGestureRecognizer(tapGestureRecognizer)
        cell.lblWord.tag = indexPath.row
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGestureRecognizer2.delegate = self
        cell.lblNote.addGestureRecognizer(tapGestureRecognizer2)
        cell.lblNote.tag = indexPath.row
        let level = item.LEVEL
        if indexPath.row == 0 {
            colors.append(cell.backgroundColor!)
            colors.append(cell.lblUnitPartSeqNum.textColor!)
            colors.append(cell.lblWord.textColor)
            colors.append(cell.lblNote.textColor)
        }
        if level != 0, let arr = vmSettings.USLEVELCOLORS![level] {
            cell.backgroundColor = UIColor(hexString: arr[0])
            cell.lblUnitPartSeqNum.textColor = UIColor(hexString: arr[1])
            cell.lblWord.textColor = UIColor(hexString: arr[1])
            cell.lblNote.textColor = UIColor(hexString: arr[1])
        } else {
            cell.backgroundColor = colors[0]
            cell.lblUnitPartSeqNum.textColor = colors[1]
            cell.lblWord.textColor = colors[2]
            cell.lblNote.textColor = colors[3]
        }
        return cell
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
            self.performSegue(withIdentifier: "edit", sender: item)
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
                if !vmSettings.selectedDictItem.DICTNAME.starts(with: "Custom") {
                    let itemDict = vmSettings.arrDictsReference.first { $0.DICTNAME == vmSettings.selectedDictItem.DICTNAME }!
                    let url = itemDict.urlString(word: item.WORD, arrAutoCorrect: vmSettings.arrAutoCorrect)
                    UIApplication.shared.openURL(URL(string: url)!)
                }
            }
            alertController.addAction(openOnlineDictAction)
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
    
    private func applyFilters() {
        vm.applyFilters(textFilter: searchBar.text!, scope: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex], levelge0only: false, textbookFilter: 0)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        applyFilters()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        applyFilters()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? WordsUnitDetailViewController {
            controller.vm = vm
            controller.item = sender as? MUnitWord ?? vm.newUnitWord()
        } else if let controller = segue.destination as? WordsDictViewController {
            controller.vm.arrWords = arrWords.map { $0.WORD }
            controller.vm.selectedWordIndex = tableView.indexPathForSelectedRow!.row
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
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        let index = sender!.view!.tag
        let word = arrWords[index].WORD
        print("DEBUG: word \(word) tapped")
        let utterance = AVSpeechUtterance(string: word)
        utterance.voice = AVSpeechSynthesisVoice(identifier: vmSettings.selectediOSVoice.VOICENAME)
        AppDelegate.synth.speak(utterance)
    }
}
