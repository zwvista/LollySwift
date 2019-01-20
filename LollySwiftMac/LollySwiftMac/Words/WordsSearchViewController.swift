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
    
    override func searchWordInTableView() {
        searchWord(word: arrWords[tableView.selectedRow].WORD)
    }

    override func addNewWord() {
        guard !newWord.isEmpty else {return}
        let mWord = MUnitWord()
        mWord.WORD = newWord
        arrWords.append(mWord)
        tableView.reloadData()
        tfNewWord.stringValue = ""
        newWord = ""
    }
}

class WordsSearchWindowController: WordsWindowController {
}
