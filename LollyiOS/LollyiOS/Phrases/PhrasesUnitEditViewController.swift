//
//  PhrasesUnitEditViewController.swift
//  LollyiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class PhrasesUnitEditViewController: UITableViewController {

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
        let cell = tableView.dequeueReusableCellWithIdentifier("WordCell", forIndexPath: indexPath)
        let m = vm.arrPhrases[indexPath.row]
        cell.textLabel!.text = m.PHRASE
        cell.detailTextLabel!.text = m.TRANSLATION
        return cell;
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
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
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? UINavigationController,
            controller2 = controller.viewControllers[0] as? PhrasesUnitDetailViewController {
            controller2.mPhrase = sender is UITableViewCell ? vm.arrPhrases[tableView.indexPathForSelectedRow!.row] : MUnitPhrase()
        }
    }
    
}