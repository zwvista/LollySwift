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
        tableView.isEditing = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.arrWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath)
        let m = vm.arrWords[(indexPath as NSIndexPath).row]
        cell.textLabel!.text = m.WORD
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return vmSettings.selectedTextbook.isSingleUnitPart
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            vm.arrWords.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let m = vm.arrWords[(sourceIndexPath as NSIndexPath).row]
        vm.arrWords.remove(at: (sourceIndexPath as NSIndexPath).row)
        vm.arrWords.insert(m, at: (destinationIndexPath as NSIndexPath).row)
        for i in 1...vm.arrWords.count {
            vm.arrWords[i - 1].SEQNUM = i
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = (segue.destination as! UINavigationController).topViewController as! WordsUnitDetailViewController
        controller.vm = vm
        if sender is UITableViewCell {
            controller.mWord = vm.arrWords[(tableView.indexPathForSelectedRow! as NSIndexPath).row]
        } else {
            let o = MUnitWord()
            let maxElem = vm.arrWords.max{ (o1, o2) in (o1.UNIT!, o1.PART!, o1.SEQNUM!) < (o2.UNIT!, o2.PART!, o2.SEQNUM!) }
            o.UNIT = maxElem?.UNIT ?? vmSettings.selectedTextbook.USUNITTO
            o.PART = maxElem?.PART ?? vmSettings.selectedTextbook.USPARTTO
            o.SEQNUM = (maxElem?.SEQNUM ?? 0) + 1
            controller.mWord = o
        }
    }
    
    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "Done" else {return}
        let controller = segue.source as! WordsUnitDetailViewController
        controller.onDone()
    }
    
}