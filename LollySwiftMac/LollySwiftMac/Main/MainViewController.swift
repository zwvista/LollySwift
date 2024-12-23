//
//  MainViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2024/12/21.
//  Copyright © 2024 趙偉. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {
    @IBOutlet weak var tabView: NSTabView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = NSStoryboard(name: "Words", bundle: nil).instantiateController(withIdentifier: "WordsUnitViewController") as! WordsUnitViewController
        let tvi = NSTabViewItem(viewController: vc)
        tvi.label = "Words in Unit"
        tabView.addTabViewItem(tvi)
    }
    
}

class MainWindowController: NSWindowController {
    
}
