//
//  WordsBaseViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa

class WordsBaseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sbTextFilter: UISearchBar!
    @IBOutlet weak var btnScopeFilter: UIButton!
    let refreshControl = UIRefreshControl()

    var vmBase: WordsBaseViewModel! { nil }
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = refreshControl
        refreshControl.isRefreshingPublisher.sink { [unowned self] _ in
            refresh()
        } ~ subscriptions
        refresh()

        vmBase.$textFilter <~> sbTextFilter.searchTextField.textProperty ~ subscriptions
        vmBase.$scopeFilter ~> (btnScopeFilter, \.titleNormal) ~ subscriptions

        func configMenu() {
            btnScopeFilter.menu = UIMenu(title: "", options: .displayInline, children: SettingsViewModel.arrScopeWordFilters.enumerated().map { index, item in
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

    func itemForRow(row: Int) -> (MWordProtocol & NSObject)? {
        nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath) as! WordsCommonCell
        let item = itemForRow(row: indexPath.row)!
        if cell.lblUnitPartSeqNum != nil {
            cell.lblUnitPartSeqNum.text = (item.value(forKey: "UNITPARTSEQNUM") as! String)
        }
        cell.lblWord.text = item.WORD
        cell.lblNote.text = item.NOTE
        cell.cardView.createCardEffect()
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let item = itemForRow(row: indexPath.row)!
        performSegue(withIdentifier: "dict", sender: item)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = itemForRow(row: indexPath.row)!
        if tableView.isEditing {
            performSegue(withIdentifier: "edit", sender: item)
        } else {
            AppDelegate.speak(string: item.WORD)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}

class WordsCommonCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var lblUnitPartSeqNum: UILabel!
    @IBOutlet weak var lblWord: UILabel!
    @IBOutlet weak var lblNote: UILabel!
}
