//
//  PhrasesUnitEditViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class PhrasesUnitEditViewController: UITableViewController, LollyProtocol {

    var vm: PhrasesUnitViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.editing = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.arrPhrases.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PhraseCell", forIndexPath: indexPath)
        let m = vm.arrPhrases[indexPath.row]
        cell.textLabel!.text = m.PHRASE
        cell.detailTextLabel!.text = m.TRANSLATION
        return cell;
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return vmSettings.currentTextbook.isSingleUnitPart
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            vm.arrPhrases.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let m = vm.arrPhrases[sourceIndexPath.row]
        vm.arrPhrases.removeAtIndex(sourceIndexPath.row)
        vm.arrPhrases.insert(m, atIndex: destinationIndexPath.row)
        for i in 1 ... vm.arrPhrases.count {
            vm.arrPhrases[i - 1].SEQNUM = i
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = (segue.destinationViewController as! UINavigationController).topViewController as! PhrasesUnitDetailViewController
        if sender is UITableViewCell {
            controller.mPhrase = vm.arrPhrases[tableView.indexPathForSelectedRow!.row]
        } else {
            let o = MUnitPhrase()
            let maxElem = vm.arrPhrases.maxElement{ (o1, o2) in (o1.UNIT, o1.PART, o1.SEQNUM) < (o2.UNIT, o2.PART, o2.SEQNUM) }
            o.UNIT = maxElem?.UNIT ?? vmSettings.currentTextbook.USUNITTO
            o.PART = maxElem?.PART ?? vmSettings.currentTextbook.USPARTTO
            o.SEQNUM = (maxElem?.SEQNUM ?? 0) + 1
            controller.mPhrase = o
        }
    }
    
}