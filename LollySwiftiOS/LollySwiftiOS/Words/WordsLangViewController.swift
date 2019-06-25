//
//  WordsLangViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import RxSwift
import AVFoundation

class WordsLangViewController: WordsBaseViewController, UISearchBarDelegate, UISearchResultsUpdating, UIGestureRecognizerDelegate {

    var vm: WordsLangViewModel!
    var arrWords: [MLangWord] {
        return searchController.isActive && searchBar.text != "" ? vm.arrWordsFiltered! : vm.arrWords
    }
    
    let disposeBag = DisposeBag()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.showBlurLoader()
        vm = WordsLangViewModel(settings: vmSettings, disposeBag: disposeBag, needCopy: false) {
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
            colors.append(cell.lblWord.textColor)
            colors.append(cell.lblNote.textColor)
        }
        if level != 0, let arr = vmSettings.USLEVELCOLORS![level] {
            cell.backgroundColor = UIColor(hexString: arr[0])
            cell.lblWord.textColor = UIColor(hexString: arr[1])
            cell.lblNote.textColor = UIColor(hexString: arr[1])
        } else {
            cell.backgroundColor = colors[0]
            cell.lblWord.textColor = colors[1]
            cell.lblNote.textColor = colors[2]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let i = indexPath.row
        let item = self.vm.arrWords[i]
        func delete() {
            self.yesNoAction(title: "delete", message: "Do you really want to delete the word \"\(item.WORD)\"?", yesHandler: { (action) in
                WordsLangViewModel.delete(item: item).subscribe().disposed(by: self.disposeBag)
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
    
    private func applyFilters() {
        vm.applyFilters(textFilter: searchBar.text!, scope: searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex], levelge0only: false)
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
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? WordsLangDetailViewController {
            controller.vm = vm
            controller.item = sender as? MLangWord ?? MLangWord()
        } else if let controller = segue.destination as? WordsDictViewController {
            controller.vm.arrWords = arrWords.map { $0.WORD }
            controller.vm.selectedWordIndex = tableView.indexPathForSelectedRow!.row
        }
    }
    
    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "Done" else {return}
        let controller = segue.source as! WordsLangDetailViewController
        controller.onDone()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        let index = sender!.view!.tag
        let utterance = AVSpeechUtterance(string: arrWords[index].WORD)
        utterance.voice = AVSpeechSynthesisVoice(identifier: vmSettings.selectediOSVoice.VOICENAME)
        AppDelegate.synth.speak(utterance)
    }
}
