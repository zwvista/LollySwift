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
import RxBinding

class WordsTextbookViewController: WordsBaseViewController {

    @IBOutlet weak var btnTextbookFilter: UIButton!

    var vm: WordsUnitViewModel!
    var arrWords: [MUnitWord] { vm.arrWordsFiltered }
    override var vmBase: WordsBaseViewModel! { vm }

    override func refresh() {
        view.showBlurLoader()
        vm = WordsUnitViewModel(settings: vmSettings, inTextbook: false, needCopy: false) { [unowned self] in
            refreshControl.endRefreshing()
            view.removeBlurLoader()
        }
        _ = vmBase.stringTextbookFilter_ ~> btnTextbookFilter.rx.title(for: .normal)
        vm.arrWordsFiltered_.subscribe { [unowned self] _ in
            tableView.reloadData()
        } ~ rx.disposeBag

        func configMenu() {
            btnTextbookFilter.menu = UIMenu(title: "", options: .displayInline, children: vmSettings.arrTextbookFilters.map(\.label).enumerated().map { index, item in
                UIAction(title: item, state: item == vmBase.stringTextbookFilter ? .on : .off) { [unowned self] _ in
                    vmBase.stringTextbookFilter = item
                    configMenu()
                }
            })
            btnTextbookFilter.showsMenuAsPrimaryAction = true
        }
        configMenu()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrWords.count
    }

    override func itemForRow(row: Int) -> (MWordProtocol & NSObject)? {
        arrWords[row]
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let i = indexPath.row
        let item = vm.arrWords[i]
        func delete() {
            yesNoAction(title: "delete", message: "Do you really want to delete the word \"\(item.WORD)\"?", yesHandler: { [unowned self] (action) in
                WordsUnitViewModel.delete(item: item).subscribe() ~ rx.disposeBag
                vm.arrWords.remove(at: i)
                tableView.deleteRows(at: [indexPath], with: .fade)
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
                let getNoteAction = UIAlertAction(title: "Retrieve Note", style: .default) { [unowned self] _ in
                    vm.getNote(index: indexPath.row).subscribe { _ in
                        tableView.reloadRows(at: [indexPath], with: .fade)
                    } ~ rx.disposeBag
                }
                alertController.addAction(getNoteAction)
                let clearNoteAction = UIAlertAction(title: "Clear Note", style: .default) { [unowned self] _ in
                    vm.clearNote(index: indexPath.row).subscribe { _ in
                        tableView.reloadRows(at: [indexPath], with: .fade)
                    } ~ rx.disposeBag
                }
                alertController.addAction(clearNoteAction)
            }
            let copyWordAction = UIAlertAction(title: "Copy Word", style: .default) { _ in iOSApi.copyText(item.WORD) }
            alertController.addAction(copyWordAction)
            let googleWordAction = UIAlertAction(title: "Google Word", style: .default) { _ in iOSApi.googleString(item.WORD) }
            alertController.addAction(googleWordAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
            alertController.addAction(cancelAction)
            present(alertController, animated: true) {}
        }

        return UISwipeActionsConfiguration(actions: [moreAction, deleteAction])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? WordsTextbookDetailViewController {
            let item = sender as! MUnitWord
            controller.vmEdit = WordsUnitDetailViewModel(vm: vm, item: item, phraseid: 0)
        } else if let controller = segue.destination as? WordsDictViewController {
            controller.vm = WordsDictViewModel(settings: vmSettings, needCopy: false, arrWords: arrWords.map(\.WORD), currentWordIndex: arrWords.firstIndex(of: sender as! MUnitWord)!) {}
        }
    }

    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "Done" else {return}
        let controller = segue.source as! WordsTextbookDetailViewController
        controller.vmEdit.onOK().subscribe { [unowned self] _ in
            tableView.reloadData()
        } ~ rx.disposeBag
    }
}
