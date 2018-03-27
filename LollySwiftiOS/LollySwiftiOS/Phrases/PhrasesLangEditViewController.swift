//
//  WPhrasesLangEditViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class PhrasesLangEditViewController: UITableViewController {

    var vm: PhrasesLangViewModel!
    
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            vm.arrPhrases.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? UINavigationController,
            let controller2 = controller.viewControllers[0] as? PhrasesLangDetailViewController {
            controller2.mPhrase = sender is UITableViewCell ? vm.arrPhrases[(tableView.indexPathForSelectedRow! as NSIndexPath).row] : MLangPhrase()
        }
    }
    
}
