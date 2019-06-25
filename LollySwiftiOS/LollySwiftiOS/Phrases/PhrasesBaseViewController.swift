//
//  PhrasesBaseViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/07/08.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import AVFoundation

class PhrasesBaseViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating, UIGestureRecognizerDelegate {
    
    // https://www.raywenderlich.com/113772/uisearchcontroller-tutorial
    let searchController = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar { return searchController.searchBar }
    
    func setupSearchController(delegate: UISearchBarDelegate & UISearchResultsUpdating) {
        // https://stackoverflow.com/questions/28326269/uisearchbar-presented-by-uisearchcontroller-in-table-header-view-animates-too-fa
        searchController.dimsBackgroundDuringPresentation = true
        searchBar.scopeButtonTitles = ["Phrase", "Translation"]
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
        searchBar.placeholder = "Search Phrases"
        searchBar.becomeFirstResponder()
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.isActive = false
    }

    func itemForRow(row: Int) -> (MPhraseProtocol & NSObject)? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhraseCell", for: indexPath) as! PhrasesCommonCell
        let item = itemForRow(row: indexPath.row)!
        if cell.lblUnitPartSeqNum != nil {
            cell.lblUnitPartSeqNum.text = (item.value(forKey: "UNITPARTSEQNUM") as! String)
        }
        cell.lblPhrase!.text = item.PHRASE
        cell.lblTranslation!.text = item.TRANSLATION
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = itemForRow(row: indexPath.row)!
        if tableView.isEditing {
            performSegue(withIdentifier: "edit", sender: item)
        } else {
            let utterance = AVSpeechUtterance(string: item.PHRASE)
            utterance.voice = AVSpeechSynthesisVoice(identifier: vmSettings.selectediOSVoice.VOICENAME)
            AppDelegate.synth.speak(utterance)
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

class PhrasesCommonCell: UITableViewCell {
    @IBOutlet weak var lblUnitPartSeqNum: UILabel!
    @IBOutlet weak var lblPhrase: UILabel!
    @IBOutlet weak var lblTranslation: UILabel!
}
