//
//  PhrasesBaseViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import RxBinding

class PhrasesBaseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sbTextFilter: UISearchBar!
    @IBOutlet weak var btnScopeFilter: UIButton!
    let refreshControl = UIRefreshControl()

    var vmBase: PhrasesBaseViewModel! { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = refreshControl
        refreshControl.rx.controlEvent(.valueChanged).subscribe { [unowned self] in
            refresh()
        } ~ rx.disposeBag
        refresh()

        _ = vmBase.textFilter_ <~> sbTextFilter.searchTextField.rx.textInput
        _ = vmBase.scopeFilter_ ~> btnScopeFilter.rx.title(for: .normal)

        func configMenu() {
            btnScopeFilter.menu = UIMenu(title: "", options: .displayInline, children: SettingsViewModel.arrScopePhraseFilters.enumerated().map { index, item in
                UIAction(title: item, state: item == vmBase.scopeFilter ? .on : .off) { [unowned self] _ in
                    vmBase.scopeFilter = item
                    configMenu()
                }
            })
            btnScopeFilter.showsMenuAsPrimaryAction = true
        }
        configMenu()
    }

    func refresh() {
    }

    func itemForRow(row: Int) -> (MPhraseProtocol & NSObject)? {
        nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhraseCell", for: indexPath) as! PhrasesCommonCell
        let item = itemForRow(row: indexPath.row)!
        if cell.lblUnitPartSeqNum != nil {
            cell.lblUnitPartSeqNum.text = (item.value(forKey: "UNITPARTSEQNUM") as! String)
        }
        cell.lblPhrase!.text = item.PHRASE
        cell.lblTranslation!.text = item.TRANSLATION
        cell.cardView.createCardEffect()
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = itemForRow(row: indexPath.row)!
        if tableView.isEditing {
            performSegue(withIdentifier: "edit", sender: item)
        } else {
            AppDelegate.speak(string: item.PHRASE)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}

class PhrasesCommonCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var lblUnitPartSeqNum: UILabel!
    @IBOutlet weak var lblPhrase: UILabel!
    @IBOutlet weak var lblTranslation: UILabel!
}
