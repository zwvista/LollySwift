//
//  WordsUnitViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class WordsUnitViewController: WordsBaseViewController {

    @IBOutlet weak var btnEdit: UIBarButtonItem!

    var vm: WordsUnitViewModel!
    var arrWords: [MUnitWord] { vm.arrWords }
    override var vmBase: WordsBaseViewModel! { vm }

    override func refresh() {
        view.showBlurLoader()
        vm = WordsUnitViewModel(settings: vmSettings, inTextbook: true) { [unowned self] in
            refreshControl.endRefreshing()
            view.removeBlurLoader()
        }
        vm.$arrWords.didSet.sink { [unowned self] _ in
            tableView.reloadData()
        } ~ subscriptions
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrWords.count
    }

    override func itemForRow(row: Int) -> (MWordProtocol & NSObject)? {
        arrWords[row]
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        vmSettings.isSingleUnitPart
    }

    private func reindex() {
        tableView.beginUpdates()
        Task {
            await vm.reindex { [unowned self] in
                tableView.reloadRows(at: [IndexPath(row: $0, section: 0)], with: .fade)
            }
            tableView.endUpdates()
        }
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        vm.arrWords.moveElement(at: sourceIndexPath.row, to: destinationIndexPath.row)
        reindex()
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let i = indexPath.row
        let item = vm.arrWords[i]
        func delete() {
            yesNoAction(title: "delete", message: "Do you really want to delete the word \"\(item.WORD)\"?", yesHandler: { [unowned self] (action) in
                Task {
                    await WordsUnitViewModel.delete(item: item)
                }
                vm.arrWords.remove(at: i)
                tableView.deleteRows(at: [indexPath], with: .fade)
                reindex()
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
            let alertController = UIAlertController(title: "Word", message: item.WORDNOTE, preferredStyle: .alert)
            let deleteAction2 = UIAlertAction(title: "Delete", style: .destructive) { _ in delete() }
            alertController.addAction(deleteAction2)
            let editAction2 = UIAlertAction(title: "Edit", style: .default) { _ in edit() }
            alertController.addAction(editAction2)
            if vmSettings.hasDictNote {
                let getNoteAction = UIAlertAction(title: "Get Note", style: .default) { [unowned self] _ in
                    Task {
                        await vm.getNote(index: indexPath.row)
                        tableView.reloadRows(at: [indexPath], with: .fade)
                    }
                }
                alertController.addAction(getNoteAction)
                let clearNoteAction = UIAlertAction(title: "Clear Note", style: .default) { [unowned self] _ in
                    Task {
                        await vm.clearNote(index: indexPath.row)
                        tableView.reloadRows(at: [indexPath], with: .fade)
                    }
                }
                alertController.addAction(clearNoteAction)
            }
            let copyWordAction = UIAlertAction(title: "Copy Word", style: .default) { _ in iOSApi.copyText(item.WORD) }
            alertController.addAction(copyWordAction)
            let googleWordAction = UIAlertAction(title: "Google Word", style: .default) { _ in iOSApi.googleString(item.WORD) }
            alertController.addAction(googleWordAction)
            let openOnlineDictAction = UIAlertAction(title: "Online Dictionary", style: .default) { _ in
                let itemDict = vmSettings.arrDictsReference.first { $0.DICTNAME == vmSettings.selectedDictReference.DICTNAME }!
                let url = itemDict.urlString(word: item.WORD, arrAutoCorrect: vmSettings.arrAutoCorrect)
                UIApplication.shared.open(URL(string: url)!)
            }
            alertController.addAction(openOnlineDictAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
            alertController.addAction(cancelAction)
            present(alertController, animated: true) {}
        }

        return UISwipeActionsConfiguration(actions: [moreAction, deleteAction])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? WordsUnitDetailViewController {
            let item = segue.identifier == "add" ? vm.newUnitWord() : sender as! MUnitWord
            controller.vmEdit = WordsUnitDetailViewModel(vm: vm, item: item, phraseid: 0)
        } else if let controller = segue.destination as? WordsDictViewController {
            controller.vm = WordsDictViewModel(settings: vmSettings, arrWords: arrWords.map(\.WORD), selectedWordIndex: arrWords.firstIndex(of: sender as! MUnitWord)!) {}
        } else if let controller = (segue.destination as? UINavigationController)?.topViewController as? WordsUnitBatchEditViewController {
            controller.vm = vm
        }
    }

    @IBAction func btnEditClicked(_ sender: AnyObject) {
        tableView.isEditing = !tableView.isEditing
        btnEdit.title = tableView.isEditing ? "Done" : "Edit"
    }

    @IBAction func btnMoreClicked(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Words", message: "More", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { [unowned self] _ in performSegue(withIdentifier: "add", sender: self) }
        alertController.addAction(addAction)

        func getNotes(ifEmpty: Bool) {
            view.showBlurLoader()
            Task {
                await vm.getNotes(ifEmpty: ifEmpty, oneComplete: { _ in }, allComplete: {
                    // https://stackoverflow.com/questions/28302019/getting-a-this-application-is-modifying-the-autolayout-engine-from-a-background
                    DispatchQueue.main.async { [unowned self] in
                        view.removeBlurLoader()
                        tableView.reloadData()
                    }
                })
            }
        }

        if vmSettings.hasDictNote {
            let getNotesAllAction = UIAlertAction(title: "Get All Notes", style: .default) { _ in
                getNotes(ifEmpty: false)
            }
            alertController.addAction(getNotesAllAction)
            let getNotesEmptyAction = UIAlertAction(title: "Get Notes If Empty", style: .default) { _ in
                getNotes(ifEmpty: true)
            }
            alertController.addAction(getNotesEmptyAction)
            let clearNotesAllAction = UIAlertAction(title: "Clear All Notes", style: .default) { [unowned self] _ in
                Task {
                    await vm.clearNotes(ifEmpty: false) { [unowned self] i in
                        tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .fade)
                    }
                }
            }
            alertController.addAction(clearNotesAllAction)
            let clearNotesEmptyAction = UIAlertAction(title: "Clear Notes If Empty", style: .default) { [unowned self] _ in
                Task {
                    await vm.clearNotes(ifEmpty: true) { [unowned self] i in
                        tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .fade)
                    }
                }
            }
            alertController.addAction(clearNotesEmptyAction)
        }
        let batchAction = UIAlertAction(title: "Batch Edit", style: .default) { [unowned self] _ in
            performSegue(withIdentifier: "batch", sender: nil)
        }
        alertController.addAction(batchAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alertController.addAction(cancelAction)
        present(alertController, animated: true) {}
    }

    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "Done" else {return}
        if let controller = segue.source as? WordsUnitDetailViewController {
            Task {
                await controller.vmEdit.onOK()
                tableView.reloadData()
                if controller.vmEdit.isAdd {
                    performSegue(withIdentifier: "add", sender: self)
                }
            }
        } else if let controller = segue.source as? WordsUnitBatchEditViewController {
            Task {
                await controller.onDone()
                tableView.reloadData()
            }
        }
    }
}
