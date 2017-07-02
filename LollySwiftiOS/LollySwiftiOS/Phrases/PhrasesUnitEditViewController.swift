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
        tableView.isEditing = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.arrPhrases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhraseCell", for: indexPath)
        let m = vm.arrPhrases[(indexPath as NSIndexPath).row]
        cell.textLabel!.text = m.PHRASE
        cell.detailTextLabel!.text = m.TRANSLATION
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
            vm.arrPhrases.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let m = vm.arrPhrases[(sourceIndexPath as NSIndexPath).row]
        vm.arrPhrases.remove(at: (sourceIndexPath as NSIndexPath).row)
        vm.arrPhrases.insert(m, at: (destinationIndexPath as NSIndexPath).row)
        for i in 1 ... vm.arrPhrases.count {
            vm.arrPhrases[i - 1].SEQNUM = i
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = (segue.destination as! UINavigationController).topViewController as! PhrasesUnitDetailViewController
        if sender is UITableViewCell {
            controller.mPhrase = vm.arrPhrases[(tableView.indexPathForSelectedRow! as NSIndexPath).row]
        } else {
            let o = MUnitPhrase()
            let maxElem = vm.arrPhrases.max{ (o1, o2) in (o1.UNIT!, o1.PART!, o1.SEQNUM!) < (o2.UNIT!, o2.PART!, o2.SEQNUM!) }
            o.UNIT = maxElem?.UNIT ?? vmSettings.selectedTextbook.USUNITTO
            o.PART = maxElem?.PART ?? vmSettings.selectedTextbook.USPARTTO
            o.SEQNUM = (maxElem?.SEQNUM ?? 0) + 1
            controller.mPhrase = o
        }
    }
    
}
