//
//  ViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import WebKit
import RxSwift

class WordsSearchViewController: WordsViewController {
    
    var arrWords = [MUnitWord]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return arrWords.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return arrWords[row]
    }
    
    @IBAction func searchDict(_ sender: Any) {
        if sender is NSToolbarItem {
            let tbItem = sender as! NSToolbarItem
            selectedDictPickerIndex = tbItem.tag
            print(tbItem.toolbar!.selectedItemIdentifier!.rawValue)
        }
        let item = vmSettings.arrDictsWord[selectedDictPickerIndex]
        let url = item.urlString(word: newWord, arrAutoCorrect: vmSettings.arrAutoCorrect)
        if item.DICTTYPENAME == "OFFLINE" {
            RestApi.getHtml(url: url).subscribe(onNext: { html in
                print(html)
                let str = item.htmlString(html, word: self.newWord)
                self.wvDict.loadHTMLString(str, baseURL: nil)
            }).disposed(by: disposeBag)
        } else {
            wvDict.load(URLRequest(url: URL(string: url)!))
            if item.DICTTYPENAME == "OFFLINE-ONLINE" {
                status = .navigating
            }
        }
    }
    
    @IBAction func addWord(_ sender: Any) {
    }
}

class WordsSearchWindowController: WordsWindowController {
    override func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        let item = super.toolbar(toolbar, itemForItemIdentifier: itemIdentifier, willBeInsertedIntoToolbar: flag)!
        item.action = #selector(WordsSearchViewController.searchDict(_:))
        return item
    }
}
