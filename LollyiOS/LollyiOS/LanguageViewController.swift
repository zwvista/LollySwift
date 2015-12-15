//
//  LanguageViewController.swift
//  LollyiOS
//
//  Created by zhaowei on 2014/11/20.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import UIKit

class LanguageViewController: UIViewController {
    let theLollyViewModel = (UIApplication.sharedApplication().delegate as! AppDelegate).theLollyViewModel
    
    @IBOutlet var tableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theLollyViewModel.arrLanguages.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "LangCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        }
        
        let m = theLollyViewModel.arrLanguages[indexPath.row]
        cell!.textLabel!.text = m.LANGNAME
        cell!.accessoryType = indexPath.row == theLollyViewModel.currentLangIndex ? .Checkmark : .None;
        return cell!;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let oldRow = theLollyViewModel.currentLangIndex;
        if indexPath.row == oldRow {return}
        let oldIndexPath = NSIndexPath(forRow: oldRow, inSection: 0)
        tableView.deselectRowAtIndexPath(oldIndexPath, animated: false)
        theLollyViewModel.currentLangIndex = indexPath.row
        tableView.reloadRowsAtIndexPaths([oldIndexPath, indexPath], withRowAnimation: .None)
    }

}
