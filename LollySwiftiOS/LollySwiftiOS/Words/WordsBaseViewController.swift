//
//  WordsBaseViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import RxBinding

class WordsBaseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sbTextFilter: UISearchBar!
    @IBOutlet weak var btnScopeFilter: UIButton!
    let refreshControl = UIRefreshControl()

    var vmBase: WordsBaseViewModel! { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        refresh(refreshControl)

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

    @objc func refresh(_ sender: UIRefreshControl) {
        refresh()
        _ = vmBase.textFilter_ <~> sbTextFilter.searchTextField.rx.textInput
        _ = vmBase.scopeFilter_ ~> btnScopeFilter.rx.title(for: .normal)
    }

    func refresh() {
    }

    func itemForRow(row: Int) -> (MWordProtocol & NSObject)? {
        nil
    }

    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath) as! WordsCommonCell
        let item = itemForRow(row: indexPath.row)!
        if cell.lblUnitPartSeqNum != nil {
            cell.lblUnitPartSeqNum.text = (item.value(forKey: "UNITPARTSEQNUM") as! String)
        }
        cell.lblWord.text = item.WORD
        cell.lblNote.text = item.NOTE
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
        print("DEBUG: \(self.className) deinit")
    }
}

class WordsCommonCell: UITableViewCell {
    @IBOutlet weak var lblUnitPartSeqNum: UILabel!
    @IBOutlet weak var lblWord: UILabel!
    @IBOutlet weak var lblNote: UILabel!
}
