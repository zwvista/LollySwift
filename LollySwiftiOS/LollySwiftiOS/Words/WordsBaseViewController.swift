//
//  WordsBaseViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class WordsBaseViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating, UIGestureRecognizerDelegate {

    // https://www.raywenderlich.com/113772/uisearchcontroller-tutorial
    let searchController = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar { return searchController.searchBar }
    var colors = [UIColor]()

    func setupSearchController(delegate: UISearchBarDelegate & UISearchResultsUpdating) {
        // https://stackoverflow.com/questions/28326269/uisearchbar-presented-by-uisearchcontroller-in-table-header-view-animates-too-fa
        //searchController.dimsBackgroundDuringPresentation = true
        searchBar.scopeButtonTitles = ["Word", "Note"]
        searchController.searchResultsUpdater = delegate
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        }
        searchBar.delegate = delegate
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        searchBar.placeholder = "Search Words"
        searchBar.becomeFirstResponder()
        definesPresentationContext = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.isActive = false
    }

    func itemForRow(row: Int) -> (MWordProtocol & NSObject)? {
        return nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath) as! WordsCommonCell
        let item = itemForRow(row: indexPath.row)!
        if cell.lblUnitPartSeqNum != nil {
            cell.lblUnitPartSeqNum.text = (item.value(forKey: "UNITPARTSEQNUM") as! String)
        }
        cell.lblWord.text = item.WORD
        cell.lblNote.text = item.NOTE
        let level = item.LEVEL
        if indexPath.row == 0 {
            colors.append(cell.backgroundColor!)
            colors.append(cell.lblWord.textColor)
            colors.append(cell.lblNote.textColor)
            if cell.lblUnitPartSeqNum != nil {
                colors.append(cell.lblUnitPartSeqNum.textColor!)
            }
        }
        if level != 0, let arr = vmSettings.USLEVELCOLORS![level] {
            cell.backgroundColor = UIColor(hexString: arr[0])
            cell.lblWord.textColor = UIColor(hexString: arr[1])
            cell.lblNote.textColor = UIColor(hexString: arr[1])
            if cell.lblUnitPartSeqNum != nil {
                cell.lblUnitPartSeqNum.textColor = UIColor(hexString: arr[1])
            }
        } else {
            cell.backgroundColor = colors[0]
            cell.lblWord.textColor = colors[1]
            cell.lblNote.textColor = colors[2]
            if cell.lblUnitPartSeqNum != nil {
                cell.lblUnitPartSeqNum.textColor = colors[3]
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let item = itemForRow(row: indexPath.row)!
        performSegue(withIdentifier: "dict", sender: item)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = itemForRow(row: indexPath.row)!
        if tableView.isEditing {
            performSegue(withIdentifier: "edit", sender: item)
        } else {
            AppDelegate.speak(string: item.WORD)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        applyFilters()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        applyFilters()
    }
    
    func applyFilters() {
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
