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
        wordsInUnit(self)
        phrasesInUnit(self)
        wordsInUnit(self)
    }

    func showTab(storyBoardName: String, viewControllerID: String, label: String) {
        let vc = NSStoryboard(name: storyBoardName, bundle: nil).instantiateController(withIdentifier: viewControllerID) as! NSViewController
        let tvi = NSTabViewItem(viewController: vc)
        tvi.label = label
        tabView.addTabViewItem(tvi)
        tabView.selectTabViewItem(tvi)
    }
    
    func findOrShowTab(storyBoardName: String, viewControllerID: String, label: String) {
        if let tvi = tabView.tabViewItems.first(where: { $0.label == label }) {
            tabView.selectTabViewItem(tvi)
        } else {
            showTab(storyBoardName: storyBoardName, viewControllerID: viewControllerID, label: label)
        }
    }

    @IBAction func search(_ sender: AnyObject) {
        findOrShowTab(storyBoardName: "Words", viewControllerID: "WordsSearchViewController", label: "Search")
    }

    @IBAction func settings(_ sender: AnyObject) {
        let vc = storyboard!.instantiateController(withIdentifier: "SettingsViewController") as! SettingsViewController
        vc.complete = { [unowned self] in
            for item in tabView.tabViewItems {
                (item.viewController as? LollyProtocol)?.settingsChanged()
            }
        }
        presentAsModalWindow(vc)
    }

    @IBAction func wordsInUnit(_ sender: AnyObject) {
        findOrShowTab(storyBoardName: "Words", viewControllerID: "WordsUnitViewController", label: "Words in Unit")
    }

    @IBAction func phrasesInUnit(_ sender: AnyObject) {
        findOrShowTab(storyBoardName: "Phrases", viewControllerID: "PhrasesUnitViewController", label: "Phrases in Unit")
    }

    @IBAction func wordsReview(_ sender: AnyObject) {
        findOrShowTab(storyBoardName: "Words", viewControllerID: "WordsReviewViewController", label: "Words Review")
    }

    @IBAction func phrasesReview(_ sender: AnyObject) {
        findOrShowTab(storyBoardName: "Phrases", viewControllerID: "PhrasesReviewViewController", label: "Phrases Review")
    }

    @IBAction func wordsInTextbook(_ sender: AnyObject) {
        findOrShowTab(storyBoardName: "Words", viewControllerID: "WordsTextbookViewController", label: "Words in Textbook")
    }

    @IBAction func phrasesInTextbook(_ sender: AnyObject) {
        findOrShowTab(storyBoardName: "Phrases", viewControllerID: "PhrasesTextbookViewController", label: "Phrases in Textbook")
    }

    @IBAction func wordsInLanguage(_ sender: AnyObject) {
        findOrShowTab(storyBoardName: "Words", viewControllerID: "WordsLangViewController", label: "Words in Language")
    }

    @IBAction func phrasesInLanguage(_ sender: AnyObject) {
        findOrShowTab(storyBoardName: "Phrases", viewControllerID: "PhrasesLangViewController", label: "Phrases in Language")
    }

    @IBAction func patternsInLanguage(_ sender: AnyObject) {
        findOrShowTab(storyBoardName: "Patterns", viewControllerID: "PatternsViewController", label: "Patterns In Language")
    }
}

class MainWindowController: NSWindowController {
    
}
