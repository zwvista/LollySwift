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
        let m = vm.arrPhrases[indexPath.row]
        cell.textLabel!.text = m.PHRASE
        cell.detailTextLabel!.text = m.TRANSLATION
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return vmSettings.isSingleUnitPart
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let i = indexPath.row
            PhrasesUnitViewModel.delete(vm.arrPhrases[i].ID) {}
            vm.arrPhrases.remove(at: i)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let m = vm.arrPhrases[(sourceIndexPath as NSIndexPath).row]
        vm.arrPhrases.remove(at: (sourceIndexPath as NSIndexPath).row)
        vm.arrPhrases.insert(m, at: (destinationIndexPath as NSIndexPath).row)
        for i in 1...vm.arrPhrases.count {
            let m = vm.arrPhrases[i - 1]
            guard m.SEQNUM != i else {continue}
            m.SEQNUM = i
            PhrasesUnitViewModel.update(m.ID, seqnum: m.SEQNUM!) {}
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = (segue.destination as! UINavigationController).topViewController as! PhrasesUnitDetailViewController
        if sender is UITableViewCell {
            controller.mPhrase = vm.arrPhrases[(tableView.indexPathForSelectedRow! as NSIndexPath).row]
        } else {
            let o = MUnitPhrase()
            o.TEXTBOOKID = vmSettings.USTEXTBOOKID
            let maxElem = vm.arrPhrases.max{ (o1, o2) in (o1.UNIT!, o1.PART!, o1.SEQNUM!) < (o2.UNIT!, o2.PART!, o2.SEQNUM!) }
            o.UNIT = maxElem?.UNIT ?? vmSettings.USUNITTO
            o.PART = maxElem?.PART ?? vmSettings.USPARTTO
            o.SEQNUM = (maxElem?.SEQNUM ?? 0) + 1
            controller.mPhrase = o
        }
    }
    
    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "Done" else {return}
        let controller = segue.source as! PhrasesUnitDetailViewController
        controller.onDone()
    }

}
