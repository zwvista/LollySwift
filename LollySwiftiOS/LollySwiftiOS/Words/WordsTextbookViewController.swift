//
//  WordsTextbookViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import RxSwift
import AVFoundation

class WordsTextbookViewController: WordsBaseViewController, UISearchBarDelegate, UISearchResultsUpdating, UIGestureRecognizerDelegate {

    var vm: WordsUnitViewModel!
    var arrWords: [MUnitWord] {
        return searchController.isActive && searchBar.text != "" ? vm.arrWordsFiltered! : vm.arrWords
    }
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.showBlurLoader()
        vm = WordsUnitViewModel(settings: vmSettings, inTextbook: false, disposeBag: disposeBag) {
            self.setupSearchController(delegate: self)
            self.tableView.reloadData()
            self.view.removeBlurLoader()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath) as! WordsTextbookCell
        let item = arrWords[indexPath.row]
        cell.lblUnitPartSeqNum.text = item.UNITPARTSEQNUM
        cell.lblWordNote.text = item.WORDNOTE
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGestureRecognizer.delegate = self
        cell.imgSpeak.addGestureRecognizer(tapGestureRecognizer)
        cell.imgSpeak.tag = indexPath.row
        let level = item.LEVEL
        if level != 0, let arr = vmSettings.USLEVELCOLORS![level] {
            cell.backgroundColor = UIColor(hexString: arr[0])
            cell.lblUnitPartSeqNum.textColor = UIColor(hexString: arr[1])
            cell.lblWordNote.textColor = UIColor(hexString: arr[1])
        }
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let i = indexPath.row
        let item = self.vm.arrWords[i]
        func delete() {
            self.yesNoAction(title: "delete", message: "Do you really want to delete the word \"\(item.WORD)\"?", yesHandler: { (action) in
                WordsUnitViewModel.delete(item: item).subscribe().disposed(by: self.disposeBag)
                self.vm.arrWords.remove(at: i)
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
            let alertController = UIAlertController(title: "Word", message: item.WORDNOTE, preferredStyle: .alert)
            let deleteAction2 = UIAlertAction(title: "Delete", style: .destructive) { _ in delete() }
            alertController.addAction(deleteAction2)
            let editAction2 = UIAlertAction(title: "Edit", style: .default) { _ in edit() }
            alertController.addAction(editAction2)
            if self.vm.mDictNote != nil {
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
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true) {}
        }
        
        return [moreAction, deleteAction]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = arrWords[indexPath.row]
        performSegue(withIdentifier: "dict", sender: item.WORD)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        vm.filterWordsForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? WordsTextbookDetailViewController {
            controller.vm = vm
            controller.item = (sender as! MUnitWord)
        } else if let controller = segue.destination as? WordsDictViewController {
            controller.vm.arrWords = arrWords.map { $0.WORD }
            controller.vm.selectedWordIndex = tableView.indexPathForSelectedRow!.row
        }
    }

    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "Done" else {return}
        let controller = segue.source as! WordsUnitDetailViewController
        controller.onDone()
        tableView.reloadData()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        let index = sender!.view!.tag
        let utterance = AVSpeechUtterance(string: arrWords[index].WORD)
        utterance.voice = AVSpeechSynthesisVoice(identifier: vm.vmSettings.selectediOSVoice.VOICENAME)
        AppDelegate.synth.speak(utterance)
    }
}

class WordsTextbookCell: UITableViewCell {
    @IBOutlet weak var lblUnitPartSeqNum: UILabel!
    @IBOutlet weak var lblWordNote: UILabel!
    @IBOutlet weak var imgSpeak: UIImageView!
}
