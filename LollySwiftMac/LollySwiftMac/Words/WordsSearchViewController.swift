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

class WordsSearchViewController: WordsBaseViewController {
    
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
    
    override func itemForRow(row: Int) -> AnyObject? {
        return arrWords[row]
    }

    override func addNewWord() {
        guard !newWord.isEmpty else {return}
        let item = MUnitWord()
        item.WORD = newWord
        item.SEQNUM = arrWords.count + 1
        item.NOTE = ""
        arrWords.append(item)
        tableView.reloadData()
        sfNewWord.stringValue = ""
        newWord = ""
    }
    
    @IBAction func refreshTableView(_ sender: Any) {
        arrWords.removeAll()
        tableView.reloadData()
    }

    @IBAction func editWord(_ sender: Any) {
    }
    
    @IBAction func getNote(_ sender: Any) {
    }
}

class WordsSearchWindowController: WordsBaseWindowController {
}
