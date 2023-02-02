//
//  WordsLangViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class WordsLangViewController: WordsBaseViewController {

    var vm: WordsLangViewModel!
    var arrWords: [MLangWord] { vm.arrWordsFiltered }
    override var vmBase: WordsBaseViewModel! { vm }

    override func refresh() {
        view.showBlurLoader()
        vm = WordsLangViewModel(settings: vmSettings, needCopy: false) { [unowned self] in
            refreshControl.endRefreshing()
            view.removeBlurLoader()
        }
        vm.$arrWordsFiltered.didSet.sink { [unowned self] _ in
            tableView.reloadData()
        } ~ subscriptions
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
                Task {
                    await WordsLangViewModel.delete(item: item)
                }
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
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
            alertController.addAction(cancelAction)
            present(alertController, animated: true) {}
        }

        return UISwipeActionsConfiguration(actions: [moreAction, deleteAction])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? WordsLangDetailViewController {
            controller.vm = vm
            controller.item = sender as? MLangWord ?? MLangWord()
        } else if let controller = segue.destination as? WordsDictViewController {
            controller.vm = WordsDictViewModel(settings: vmSettings, needCopy: false, arrWords: arrWords.map(\.WORD), currentWordIndex: arrWords.firstIndex(of: sender as! MLangWord)!) {}
        }
    }

    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "Done" else {return}
        let controller = segue.source as! WordsLangDetailViewController
        Task {
            await controller.vmEdit.onOK()
            tableView.reloadData()
        }
    }
}
