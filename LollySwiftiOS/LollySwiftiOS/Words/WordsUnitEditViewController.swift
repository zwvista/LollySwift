//
//  WordsUnitEditViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class WordsUnitEditViewController: UITableViewController, LollyProtocol {

    var vm: WordsUnitViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.editing = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.arrWords.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WordCell", forIndexPath: indexPath)
        let m = vm.arrWords[indexPath.row]
        cell.textLabel!.text = m.WORD
        return cell;
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return vmSettings.selectedTextbook.isSingleUnitPart
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            vm.arrWords.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let m = vm.arrWords[sourceIndexPath.row]
        vm.arrWords.removeAtIndex(sourceIndexPath.row)
        vm.arrWords.insert(m, atIndex: destinationIndexPath.row)
        for i in 1 ... vm.arrWords.count {
            vm.arrWords[i - 1].SEQNUM = i
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = (segue.destinationViewController as! UINavigationController).topViewController as! WordsUnitDetailViewController
        if sender is UITableViewCell {
            controller.mWord = vm.arrWords[tableView.indexPathForSelectedRow!.row]
        } else {
            let o = MUnitWord()
            let maxElem = vm.arrWords.maxElement{ (o1, o2) in (o1.UNIT, o1.PART, o1.SEQNUM) < (o2.UNIT, o2.PART, o2.SEQNUM) }
            o.UNIT = maxElem?.UNIT ?? vmSettings.selectedTextbook.USUNITTO
            o.PART = maxElem?.PART ?? vmSettings.selectedTextbook.USPARTTO
            o.SEQNUM = (maxElem?.SEQNUM ?? 0) + 1
            controller.mWord = o
        }
    }
    
}