//
//  PhrasesUnitsViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import RxSwift
import NSObject_Rx

class PhrasesUnitViewController: PhrasesBaseViewController {
    
    var vm: PhrasesUnitViewModel!
    var arrPhrases: [MUnitPhrase] { sbTextFilter.text != "" ? vm.arrPhrasesFiltered! : vm.arrPhrases }
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.showBlurLoader()
        vm = PhrasesUnitViewModel(settings: vmSettings, inTextbook: true, needCopy: false) {
            self.tableView.reloadData()
            self.view.removeBlurLoader()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrPhrases.count
    }
    
    override func itemForRow(row: Int) -> (MPhraseProtocol & NSObject)? {
        arrPhrases[row]
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        vmSettings.isSingleUnitPart
    }
    
    private func reindex() {
        tableView.beginUpdates()
        vm.reindex {
            self.tableView.reloadRows(at: [IndexPath(row: $0, section: 0)], with: .fade)
        }
        tableView.endUpdates()
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = vm.arrPhrases[(sourceIndexPath as NSIndexPath).row]
        vm.arrPhrases.remove(at: (sourceIndexPath as NSIndexPath).row)
        vm.arrPhrases.insert(item, at: (destinationIndexPath as NSIndexPath).row)
        tableView.beginUpdates()
        vm.reindex {
            tableView.reloadRows(at: [IndexPath(row: $0, section: 0)], with: .fade)
        }
        tableView.endUpdates()
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let i = indexPath.row
        let item = self.vm.arrPhrases[i]
        func delete() {
            self.yesNoAction(title: "delete", message: "Do you really want to delete the phrase \"\(item.PHRASE)\"?", yesHandler: { (action) in
                PhrasesUnitViewModel.delete(item: item).subscribe() ~ self.rx.disposeBag
                self.vm.arrPhrases.remove(at: i)
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
    
    override func applyFilters() {
        vm.applyFilters(textFilter: sbTextFilter.text!, scope: btnScopeFilter.titleLabel!.text!, textbookFilter: 0)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? PhrasesUnitDetailViewController {
            let item = segue.identifier == "Add" ? vm.newUnitPhrase() : sender as! MUnitPhrase
            controller.startEdit(vm: vm, item: item, wordid: 0)
        } else if let controller = (segue.destination as? UINavigationController)?.topViewController as? PhrasesUnitBatchViewController {
            controller.vm = vm
        }
    }
    
    @IBAction func btnMoreClicked(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Phrases", message: "More", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in self.performSegue(withIdentifier: "add", sender: self) }
        alertController.addAction(addAction)
        
        let batchAction = UIAlertAction(title: "Batch Edit", style: .default) { _ in
            self.performSegue(withIdentifier: "batch", sender: nil)
        }
        alertController.addAction(batchAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true) {}
    }

    @IBAction func btnEditClicked(_ sender: AnyObject) {
        tableView.isEditing = !tableView.isEditing
        btnEdit.title = tableView.isEditing ? "Done" : "Edit"
    }
    
    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "Done" else {return}
        let controller = segue.source as! PhrasesUnitDetailViewController
        controller.vmEdit.onOK().subscribe(onNext: {
            self.tableView.reloadData()
            if controller.vmEdit.isAdd {
                self.performSegue(withIdentifier: "add", sender: self)
            }
        }) ~ rx.disposeBag
    }
}
