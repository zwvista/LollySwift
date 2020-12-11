//
//  PhrasesLangViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import RxSwift
import NSObject_Rx

class PhrasesLangViewController: PhrasesBaseViewController {
    
    var vm: PhrasesLangViewModel!
    var arrPhrases: [MLangPhrase] { sbTextFilter.text != "" ? vm.arrPhrasesFiltered! : vm.arrPhrases }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.showBlurLoader()
        vm = PhrasesLangViewModel(settings: vmSettings, needCopy: false) {
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let i = indexPath.row
        let item = self.vm.arrPhrases[i]
        func delete() {
            self.yesNoAction(title: "delete", message: "Do you really want to delete the phrase \"\(item.PHRASE)\"?", yesHandler: { (action) in
                PhrasesLangViewModel.delete(item: item).subscribe() ~ self.rx.disposeBag
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
        vm.applyFilters(textFilter: sbTextFilter.text!, scope: btnScopeFilter.titleLabel!.text!)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? PhrasesLangDetailViewController {
            controller.vm = vm
            controller.item = sender as? MLangPhrase ?? MLangPhrase()
        }
    }
    
    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "Done" else {return}
        let controller = segue.source as! PhrasesLangDetailViewController
        controller.vmEdit.onOK().subscribe(onNext: {
            self.tableView.reloadData()
        }) ~ rx.disposeBag
    }
}
