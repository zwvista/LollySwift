//
//  DictionaryViewController.swift
//  LollyiOS
//
//  Created by zhaowei on 2014/11/20.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import UIKit

class DictionaryViewController: UIViewController {
    let theWordsOnlineViewModel = (UIApplication.sharedApplication().delegate as! AppDelegate).theWordsOnlineViewModel
    
    @IBOutlet var tableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theWordsOnlineViewModel.arrDictAll.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "DictCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        }
        
        let m = theWordsOnlineViewModel.arrDictAll[indexPath.row]
        cell!.textLabel!.text = m.DICTNAME
        cell!.detailTextLabel!.text = m.URL
        cell!.accessoryType = indexPath.row == theWordsOnlineViewModel.currentDictIndex ? .Checkmark : .None;
        return cell!;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let oldRow = theWordsOnlineViewModel.currentDictIndex;
        if indexPath.row == oldRow {return}
        let oldIndexPath = NSIndexPath(forRow: oldRow, inSection: 0)
        tableView.deselectRowAtIndexPath(oldIndexPath, animated: false)
        theWordsOnlineViewModel.currentDictIndex = indexPath.row
        tableView.reloadRowsAtIndexPaths([oldIndexPath, indexPath], withRowAnimation: .None)
    }

}
