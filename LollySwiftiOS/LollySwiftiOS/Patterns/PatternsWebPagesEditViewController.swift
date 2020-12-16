//
//  PatternsWebPagesEditViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import NSObject_Rx

class PatternsWebPagesEditViewController: UITableViewController {
    
    var vm: PatternsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        vm.getWebPages().subscribe(onNext: {
        }) ~ rx.disposeBag
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? PatternsWebPageEditViewController {
            let item = segue.identifier == "add" ? vm.newPatternWebPage() : vm.currentWebPage
            controller.startEdit(item: item)
        }
    }

    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "Done" else {return}
        if let controller = segue.source as? PatternsWebPageEditViewController {
            controller.vmEdit.onOK().subscribe(onNext: {
            }) ~ rx.disposeBag
        }
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
