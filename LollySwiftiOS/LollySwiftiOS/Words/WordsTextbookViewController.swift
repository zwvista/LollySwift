//
//  WordsTextbookViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import RxSwift
import NSObject_Rx

class WordsTextbookViewController: WordsBaseViewController {

    var vm: WordsUnitViewModel!
    var arrWords: [MUnitWord] { sbTextFilter.text != "" ? vm.arrWordsFiltered! : vm.arrWords }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.showBlurLoader()
        vm = WordsUnitViewModel(settings: vmSettings, inTextbook: false, needCopy: false) {
            self.tableView.reloadData()
            self.view.removeBlurLoader()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrWords.count
    }
    
    override func itemForRow(row: Int) -> (MWordProtocol & NSObject)? {
        arrWords[row]
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let i = indexPath.row
        let item = self.vm.arrWords[i]
        func delete() {
            self.yesNoAction(title: "delete", message: "Do you really want to delete the word \"\(item.WORD)\"?", yesHandler: { (action) in
                WordsUnitViewModel.delete(item: item).subscribe() ~ self.rx.disposeBag
                self.vm.arrWords.remove(at: i)
                tableView.deleteRows(at: [indexPath], with: .fade)
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
                    self.vm.getNote(index: indexPath.row).subscribe(onNext: {
                        self.tableView.reloadRows(at: [indexPath], with: .fade)
                    }) ~ self.rx.disposeBag
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
    
    override func applyFilters() {
        vm.applyFilters(textFilter: sbTextFilter.text!, scope: btnScopeFilter.titleLabel!.text!, textbookFilter: 0)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? WordsTextbookDetailViewController {
            let item = sender as! MUnitWord
            controller.startEdit(vm: vm, item: item, phraseid: 0)
        } else if let controller = segue.destination as? WordsDictViewController {
            controller.vm.arrWords = arrWords.map { $0.WORD }
            controller.vm.currentWordIndex = vm.arrWords.indexes(of: sender as! MUnitWord)[0]
        }
    }

    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "Done" else {return}
        let controller = segue.source as! WordsTextbookDetailViewController
        controller.vmEdit.onOK().subscribe(onNext: {
            self.tableView.reloadData()
        }) ~ rx.disposeBag
    }
}
