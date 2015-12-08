//
//  LanguageViewController.swift
//  LollyiOS
//
//  Created by zhaowei on 2014/11/20.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import UIKit

class LanguageViewController: UIViewController {
    let theLollyObject = (UIApplication.sharedApplication().delegate as! AppDelegate).theLollyObject
    
    @IBOutlet var tableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theLollyObject.arrLanguages.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "LangCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
        }
        
        let m = theLollyObject.arrLanguages[indexPath.row]
        cell!.textLabel!.text = m.LANGNAME
        cell!.accessoryType = indexPath.row == theLollyObject.currentLangIndex ? .Checkmark : .None;
        return cell!;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let oldRow = theLollyObject.currentLangIndex;
        if indexPath.row == oldRow {return}
        let oldIndexPath = NSIndexPath(forRow: oldRow, inSection: 0)
        tableView.deselectRowAtIndexPath(oldIndexPath, animated: false)
        theLollyObject.currentLangIndex = indexPath.row
        tableView.reloadRowsAtIndexPaths([oldIndexPath, indexPath], withRowAnimation: .None)
    }

}