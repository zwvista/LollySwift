//
//  WordsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/01/05.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa

class WordsWindowController: NSWindowController, NSToolbarDelegate, LollyProtocol {
    
    @IBOutlet weak var toolbar: NSToolbar!
    
    @objc var vm: SettingsViewModel {return vmSettings}
    var toolbarItemCount: Int { return 1 }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.settingsChanged()
        }
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        let dictName = itemIdentifier.rawValue
        item.label = dictName
        item.paletteLabel = dictName
        item.target = contentViewController
        item.image = NSImage(named: NSImage.bookmarksTemplateName)
        item.tag = vmSettings.arrDictsOnline.firstIndex { $0.DICTNAME == dictName }!
        return item
    }
    
    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return vmSettings.arrDictsOnline.map { NSToolbarItem.Identifier($0.DICTNAME!) }
    }
    
    func settingsChanged() {
        while toolbar.items.count > toolbarItemCount {
            toolbar.removeItem(at: toolbarItemCount)
        }
        for (i, dict) in vmSettings.arrDictsOnline.enumerated() {
            let itemIdentifier = NSToolbarItem.Identifier(dict.DICTNAME!)
            toolbar.insertItem(withItemIdentifier: itemIdentifier, at: toolbarItemCount + i)
            if i == vmSettings.selectedDictOnlineIndex {
                toolbar.selectedItemIdentifier = itemIdentifier
            }
        }
    }
}
