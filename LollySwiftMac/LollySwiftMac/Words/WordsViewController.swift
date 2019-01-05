//
//  WordsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/01/05.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa

class WordsViewController: NSViewController, LollyProtocol {
    var selectedDictOnlineIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
    }
    func settingsChanged() {
        selectedDictOnlineIndex = vmSettings.selectedDictOnlineIndex
    }
}

class WordsWindowController: NSWindowController, NSToolbarDelegate, LollyProtocol {
    
    @IBOutlet weak var toolbar: NSToolbar!
    // Could not find outlet collection
    // https://stackoverflow.com/questions/24805180/swift-put-multiple-iboutlets-in-an-array
    // @IBOutlet var tbiDicts: [NSToolbarItem]!
    @IBOutlet weak var tbiDict0: NSToolbarItem!
    @IBOutlet weak var tbiDict1: NSToolbarItem!
    @IBOutlet weak var tbiDict2: NSToolbarItem!
    @IBOutlet weak var tbiDict3: NSToolbarItem!
    @IBOutlet weak var tbiDict4: NSToolbarItem!
    @IBOutlet weak var tbiDict5: NSToolbarItem!
    @IBOutlet weak var tbiDict6: NSToolbarItem!
    @IBOutlet weak var tbiDict7: NSToolbarItem!
    @IBOutlet weak var tbiDict8: NSToolbarItem!
    @IBOutlet weak var tbiDict9: NSToolbarItem!
    @objc var vm: SettingsViewModel {return vmSettings}
    var toolbarItemCount: Int { return 1 }
    
    var identifiers: [NSToolbarItem.Identifier]!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        print(toolbar.items.count)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.settingsChanged()
        }
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        let dictName = itemIdentifier.rawValue
        let i = vmSettings.arrDictsOnline.firstIndex { $0.DICTNAME == dictName }!
        let item = self.value(forKey: "tbiDict\(i)") as! NSToolbarItem
        item.label = dictName
        item.target = contentViewController
        if i == vmSettings.selectedDictOnlineIndex {
            toolbar.selectedItemIdentifier = item.itemIdentifier
        }
        return item
    }
    
    func settingsChanged() {
        while toolbar.items.count > toolbarItemCount {
            toolbar.removeItem(at: toolbarItemCount)
        }
        for i in 0..<vmSettings.arrDictsOnline.count {
            let itemIdentifier = NSToolbarItem.Identifier(vmSettings.arrDictsOnline[i].DICTNAME!)
            toolbar.insertItem(withItemIdentifier: itemIdentifier, at: toolbarItemCount + i)
        }
    }
}
