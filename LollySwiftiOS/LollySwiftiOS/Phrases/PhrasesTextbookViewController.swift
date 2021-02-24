//
//  PhrasesTextbookViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import DropDown
import RxSwift
import NSObject_Rx

class PhrasesTextbookViewController: PhrasesBaseViewController {
    
    var vm: PhrasesUnitViewModel!
    var arrPhrases: [MUnitPhrase] { vm.arrPhrasesFiltered ?? vm.arrPhrases }

    @IBOutlet weak var btnTextbookFilter: UIButton!
    let ddTextbookFilter = DropDown()
    override var vmBase: PhrasesBaseViewModel! { vm }

    override func viewDidLoad() {
        super.viewDidLoad()
        ddTextbookFilter.anchorView = btnTextbookFilter
        ddTextbookFilter.dataSource = vmSettings.arrTextbookFilters.map(\.label)
        ddTextbookFilter.selectRow(0)
        ddTextbookFilter.selectionAction = { [unowned self] (index: Int, item: String) in
            self.vmBase.stringTextbookFilter.accept(item)
            self.searchBarSearchButtonClicked(self.sbTextFilter)
        }
        _ = vmBase.stringTextbookFilter ~> btnTextbookFilter.rx.title(for: .normal)
    }
    
    override func refresh() {
        view.showBlurLoader()
        vm = PhrasesUnitViewModel(settings: vmSettings, inTextbook: false, needCopy: false) {
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
            self.view.removeBlurLoader()
        }
    }
    
    @IBAction func showTextbookFilterDropDown(_ sender: AnyObject) {
        ddTextbookFilter.show()
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

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let i = indexPath.row
        let item = self.vm.arrPhrases[i]
        func delete() {
            self.yesNoAction(title: "delete", message: "Do you really want to delete the phrase \"\(item.PHRASE)\"?", yesHandler: { (action) in
                PhrasesUnitViewModel.delete(item: item).subscribe() ~ self.rx.disposeBag
                self.vm.arrPhrases.remove(at: i)
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
        vm.applyFilters()
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let controller = (segue.destination as? UINavigationController)?.topViewController as? PhrasesTextbookDetailViewController else {return}
        let item = sender as! MUnitPhrase
        controller.startEdit(vm: vm, item: item, wordid: 0)
    }
    
    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "Done" else {return}
        let controller = segue.source as! PhrasesTextbookDetailViewController
        controller.vmEdit.onOK().subscribe(onNext: {
            self.tableView.reloadData()
        }) ~ rx.disposeBag
    }
}
