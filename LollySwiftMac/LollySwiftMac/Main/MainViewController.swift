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
        showTab(storyBoardName: "Words", viewControllerID: "WordsUnitViewController", label: "Words in Unit")
        showTab(storyBoardName: "Phrases", viewControllerID: "PhrasesUnitViewController", label: "Phrases in Unit")
        showTab(storyBoardName: "Words", viewControllerID: "WordsTextbookViewController", label: "Words in Textbook")
        showTab(storyBoardName: "Phrases", viewControllerID: "PhrasesTextbookViewController", label: "Phrases in Textbook")
    }

    func showTab(storyBoardName: String, viewControllerID: String, label: String) {
        let vc = NSStoryboard(name: storyBoardName, bundle: nil).instantiateController(withIdentifier: viewControllerID) as! NSViewController
        let tvi = NSTabViewItem(viewController: vc)
        tvi.label = label
        tabView.addTabViewItem(tvi)
    }
}

class MainWindowController: NSWindowController {
    
}
