//
//  PhrasesTextbookViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import Combine

class PhrasesTextbookViewController: PhrasesBaseViewController {

    @IBOutlet weak var btnTextbookFilter: UIButton!

    var vm: PhrasesUnitViewModel!
    var arrPhrases: [MUnitPhrase] { vm.arrPhrasesFiltered }
    override var vmBase: PhrasesBaseViewModel! { vm }

    override func refresh() {
        view.showBlurLoader()
        vm = PhrasesUnitViewModel(settings: vmSettings, inTextbook: false, needCopy: false) { [unowned self] in
            refreshControl.endRefreshing()
            view.removeBlurLoader()
        }
        vmBase.$stringTextbookFilter ~> (btnTextbookFilter, \.titleNormal) ~ subscriptions
        vm.$arrPhrasesFiltered.didSet.sink { [unowned self] _ in
            tableView.reloadData()
        } ~ subscriptions

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
        arrPhrases.count
    }

    override func itemForRow(row: Int) -> (MPhraseProtocol & NSObject)? {
        arrPhrases[row]
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        vmSettings.isSingleUnitPart
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = vm.arrPhrases[(sourceIndexPath as NSIndexPath).row]
        vm.arrPhrases.remove(at: (sourceIndexPath as NSIndexPath).row)
        vm.arrPhrases.insert(item, at: (destinationIndexPath as NSIndexPath).row)
        tableView.beginUpdates()
//        vm.reindex {
//            tableView.reloadRows(at: [IndexPath(row: $0, section: 0)], with: .fade)
//        }
        tableView.endUpdates()
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let i = indexPath.row
        let item = vm.arrPhrases[i]
        func delete() {
            yesNoAction(title: "delete", message: "Do you really want to delete the phrase \"\(item.PHRASE)\"?", yesHandler: { [unowned self] (action) in
                Task {
                     await PhrasesUnitViewModel.delete(item: item)
                }
                vm.arrPhrases.remove(at: i)
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
            present(alertController, animated: true) {}
        }

        return UISwipeActionsConfiguration(actions: [moreAction, deleteAction])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let controller = (segue.destination as? UINavigationController)?.topViewController as? PhrasesTextbookDetailViewController else {return}
        let item = sender as! MUnitPhrase
        controller.vmEdit = PhrasesUnitDetailViewModel(vm: vm, item: item, wordid: 0)
    }

    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "Done" else {return}
        let controller = segue.source as! PhrasesTextbookDetailViewController
        Task {
            await controller.vmEdit.onOK()
            tableView.reloadData()
        }
    }
}
