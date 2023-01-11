//
//  PhrasesUnitsViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import Combine

class PhrasesUnitViewController: PhrasesBaseViewController {

    @IBOutlet weak var btnEdit: UIBarButtonItem!

    var vm: PhrasesUnitViewModel!
    var arrPhrases: [MUnitPhrase] { vm.arrPhrasesFiltered }
    override var vmBase: PhrasesBaseViewModel! { vm }

    override func refresh() {
        view.showBlurLoader()
        vm = PhrasesUnitViewModel(settings: vmSettings, inTextbook: true, needCopy: false) {
            self.refreshControl.endRefreshing()
            self.view.removeBlurLoader()
        }
        vm.$arrPhrasesFiltered.didSet.sink { [unowned self] _ in
            tableView.reloadData()
        } ~ subscriptions
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
        Task {
            await vm.reindex {
                self.tableView.reloadRows(at: [IndexPath(row: $0, section: 0)], with: .fade)
            }
            tableView.endUpdates()
        }
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        vm.arrPhrases.moveElement(at: sourceIndexPath.row, to: destinationIndexPath.row)
        reindex()
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let i = indexPath.row
        let item = self.vm.arrPhrases[i]
        func delete() {
            self.yesNoAction(title: "delete", message: "Do you really want to delete the phrase \"\(item.PHRASE)\"?", yesHandler: { (action) in
                Task {
                    await PhrasesUnitViewModel.delete(item: item)
                }
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
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _,_,_ in delete() }
        let editAction = UIContextualAction(style: .normal, title: "Edit") { _,_,_ in edit() }
        editAction.backgroundColor = .blue
        let moreAction = UIContextualAction(style: .normal, title: "More") { [unowned self] _,_,_ in
            let alertController = UIAlertController(title: "Phrase", message: item.PHRASE, preferredStyle: .alert)
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

        return UISwipeActionsConfiguration(actions: [moreAction, deleteAction])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? PhrasesUnitDetailViewController {
            let item = segue.identifier == "add" ? vm.newUnitPhrase() : sender as! MUnitPhrase
            controller.vmEdit = PhrasesUnitDetailViewModel(vm: vm, item: item, wordid: 0)
        } else if let controller = (segue.destination as? UINavigationController)?.topViewController as? PhrasesUnitBatchEditViewController {
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
        Task {
            await controller.vmEdit.onOK()
            self.tableView.reloadData()
            if controller.vmEdit.isAdd {
                self.performSegue(withIdentifier: "add", sender: self)
            }
        }
    }
}
