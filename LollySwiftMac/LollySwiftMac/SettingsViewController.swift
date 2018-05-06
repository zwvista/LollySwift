//
//  SettingsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/23.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa

@objcMembers
class SettingsViewController: NSViewController {
    
    var vm: SettingsViewModel {
        return AppDelegate.theSettingsViewModel
    }
    @IBOutlet weak var acLanguages: NSArrayController!
    @IBOutlet weak var acDictsOnlne: NSArrayController!
    @IBOutlet weak var acDictsNote: NSArrayController!
    @IBOutlet weak var acTextbooks: NSArrayController!
    @IBOutlet weak var acUnits: NSArrayController!
    @IBOutlet weak var acParts: NSArrayController!
    @IBOutlet weak var tfUnitsInAllFrom: NSTextField!
    @IBOutlet weak var tfUnitsInAllTo: NSTextField!
    @IBOutlet weak var pubLanguages: NSPopUpButton!
    @IBOutlet weak var pubDictsOnline: NSPopUpButton!
    @IBOutlet weak var pubDictsNote: NSPopUpButton!
    @IBOutlet weak var pubTextbooks: NSPopUpButton!
    @IBOutlet weak var pubUnitFrom: NSPopUpButton!
    @IBOutlet weak var pubUnitTo: NSPopUpButton!
    @IBOutlet weak var pubPartFrom: NSPopUpButton!
    @IBOutlet weak var pubPartTo: NSPopUpButton!
    @IBOutlet weak var btnUnitPartTo: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.getData {
            self.updateLang()
        }
    }
    @IBAction func close(_ sender: AnyObject) {
        let application = NSApplication.shared
        application.stopModal()
        // http://stackoverflow.com/questions/5711367/os-x-how-can-a-nsviewcontroller-find-its-window
        self.view.window?.close()
        for w in NSApplication.shared.windows {
            guard let v = w.contentViewController as? LollyProtocol else {continue}
            v.settingsChanged()
        }
    }
    
    @IBAction func langSelected(_ sender: AnyObject) {
        vm.setSelectedLangIndex(pubLanguages.indexOfSelectedItem) {
            self.vm.updateLang {
                self.updateLang()
            }
        }
    }
    
    @IBAction func dictOnlineSelected(_ sender: AnyObject) {
        vm.selectedDictOnlineIndex = pubDictsOnline.indexOfSelectedItem
        vm.updateDictOnline {
            self.updateDictOnline()
        }
    }
    
    @IBAction func dictNoteSelected(_ sender: AnyObject) {
        vm.selectedDictNoteIndex = pubDictsNote.indexOfSelectedItem
        vm.updateDictNote {
            self.updateDictOnline()
        }
    }

    @IBAction func textbookSelected(_ sender: AnyObject) {
        vm.selectedTextbookIndex = pubTextbooks.indexOfSelectedItem
        vm.updateTextbook {
            self.updateTextbook()
        }
    }
    
    @IBAction func btnUnitPartToClicked(_ sender: AnyObject) {
        let b = btnUnitPartTo.state == .on
        pubUnitTo.isEnabled = b
        pubPartTo.isEnabled = b
        if sender !== self && !b {updateUnitPartTo()}
    }
    
    @IBAction func unitFromSelected(_ sender: AnyObject) {
        guard vm.USUNITFROM != pubUnitFrom.indexOfSelectedItem + 1 else {return}
        vm.USUNITFROM = pubUnitFrom.indexOfSelectedItem + 1
        vm.updateUnitFrom {
            if self.btnUnitPartTo.state == .off || self.vm.isInvalidUnitPart {self.updateUnitPartTo()}
        }
    }
    
    @IBAction func unitToSelected(_ sender: AnyObject) {
        guard vm.USUNITTO != pubUnitTo.indexOfSelectedItem + 1 else {return}
        vm.USUNITTO = pubUnitTo.indexOfSelectedItem + 1
        vm.updateUnitTo {
            if self.vm.isInvalidUnitPart {self.updateUnitPartFrom()}
        }
    }
    
    @IBAction func partFromSelected(_ sender: AnyObject) {
        guard vm.USPARTFROM != pubPartFrom.indexOfSelectedItem + 1 else {return}
        vm.USPARTFROM = pubPartFrom.indexOfSelectedItem + 1
        vm.updatePartFrom {
            if self.btnUnitPartTo.state == .off || self.vm.isInvalidUnitPart {self.updateUnitPartTo()}
        }
    }
    
    @IBAction func partToSelected(_ sender: AnyObject) {
        guard vm.USPARTTO != pubPartTo.indexOfSelectedItem + 1 else {return}
        vm.USPARTTO = pubPartTo.indexOfSelectedItem + 1
        vm.updatePartTo {
            if self.vm.isInvalidUnitPart {self.updateUnitPartFrom()}
        }
    }

    func updateLang() {
        acLanguages.content = vm.arrLanguages
        updateDictOnline()
        updateDictNote()
        updateTextbook()
    }
    
    func updateDictOnline() {
        acDictsOnlne.content = vm.arrDictsOnline
    }
    
    func updateDictNote() {
        acDictsNote.content = vm.arrDictsNote
    }

    func updateTextbook() {
        acTextbooks.content = vm.arrTextbooks
        let item = vm.selectedTextbook
        let unitsInAll = "(\(item.UNITS) in all)"
        tfUnitsInAllFrom.stringValue = unitsInAll
        tfUnitsInAllTo.stringValue = unitsInAll
        acUnits.content = vm.arrUnits
        acParts.content = vm.arrParts
        pubUnitFrom.selectItem(at: vm.USUNITFROM - 1)
        pubUnitTo.selectItem(at: vm.USUNITTO - 1)
        pubPartFrom.selectItem(at: vm.USPARTFROM - 1)
        pubPartTo.selectItem(at: vm.USPARTTO - 1)
        btnUnitPartTo.state = vm.isSingleUnitPart ? .off : .on
        btnUnitPartToClicked(self)
    }
    
    func updateUnitPartFrom() {
        if vm.USUNITFROM != vm.USUNITTO {
            vm.USUNITFROM = vm.USUNITTO
            vm.updateUnitFrom {
                self.pubUnitFrom.selectItem(at: self.pubUnitTo.indexOfSelectedItem)
            }
        }
        if vm.USPARTFROM != vm.USPARTTO {
            vm.USPARTFROM = vm.USPARTTO
            vm.updatePartFrom {
                self.pubPartFrom.selectItem(at: self.pubPartTo.indexOfSelectedItem)
            }
        }
    }
    
    func updateUnitPartTo() {
        if vm.USUNITTO != vm.USUNITFROM {
            vm.USUNITTO = vm.USUNITFROM
            vm.updateUnitTo {
                self.pubUnitTo.selectItem(at: self.pubUnitFrom.indexOfSelectedItem)
            }
        }
        if vm.USPARTTO != vm.USPARTFROM {
            vm.USPARTTO = vm.USPARTFROM
            vm.updatePartTo {
                self.pubPartTo.selectItem(at: self.pubPartFrom.indexOfSelectedItem)
            }
        }
    }

}
