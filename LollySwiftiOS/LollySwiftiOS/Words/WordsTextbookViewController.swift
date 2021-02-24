//
//  WordsTextbookViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import DropDown
import RxSwift
import NSObject_Rx

class WordsTextbookViewController: WordsBaseViewController {

    var vm: WordsUnitViewModel!
    var arrWords: [MUnitWord] { vm.arrWordsFiltered ?? vm.arrWords }
    
    @IBOutlet weak var btnTextbookFilter: UIButton!
    let ddTextbookFilter = DropDown()
    override var vmBase: WordsBaseViewModel! { vm }

    override func viewDidLoad() {
        super.viewDidLoad()
        ddTextbookFilter.anchorView = btnTextbookFilter
        ddTextbookFilter.dataSource = vmSettings.arrTextbookFilters.map(\.label)
        ddTextbookFilter.selectRow(0)
        ddTextbookFilter.selectionAction = { [unowned self] (index: Int, item: String) in
            btnTextbookFilter.setTitle(item, for: .normal)
            self.searchBarSearchButtonClicked(self.sbTextFilter)
        }
        btnTextbookFilter.setTitle(vmSettings.arrTextbookFilters[0].label, for: .normal)
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        refresh(refreshControl)
        _ = vm.textFilter <~> sbTextFilter.rx.text.orEmpty
        _ = vm.scopeFilter ~> btnScopeFilter.rx.title(for: .normal)
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        view.showBlurLoader()
        vm = WordsUnitViewModel(settings: vmSettings, inTextbook: false, needCopy: false) {
            sender.endRefreshing()
            self.tableView.reloadData()
            self.view.removeBlurLoader()
        }
    }
    
    @IBAction func showTextbookFilterDropDown(_ sender: AnyObject) {
        ddTextbookFilter.show()
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
                let getNoteAction = UIAlertAction(title: "Retrieve Note", style: .default) { _ in
                    self.vm.getNote(index: indexPath.row).subscribe(onNext: {
                        self.tableView.reloadRows(at: [indexPath], with: .fade)
                    }) ~ self.rx.disposeBag
                }
                alertController.addAction(getNoteAction)
                let clearNoteAction = UIAlertAction(title: "Clear Note", style: .default) { _ in
                    self.vm.clearNote(index: indexPath.row).subscribe(onNext: {
                        self.tableView.reloadRows(at: [indexPath], with: .fade)
                    }) ~ self.rx.disposeBag
                }
                alertController.addAction(clearNoteAction)
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
        vm.applyFilters()
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? WordsTextbookDetailViewController {
            let item = sender as! MUnitWord
            controller.startEdit(vm: vm, item: item, phraseid: 0)
        } else if let controller = segue.destination as? WordsDictViewController {
            controller.vm.arrWords = arrWords.map(\.WORD)
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
