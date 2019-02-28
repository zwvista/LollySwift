//
//  SettingsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/23.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

@objcMembers
class SettingsViewController: NSViewController {
    
    var vm: SettingsViewModel {
        return AppDelegate.theSettingsViewModel
    }
    @IBOutlet weak var acLanguages: NSArrayController!
    @IBOutlet weak var acDictItems: NSArrayController!
    @IBOutlet weak var acDictsNote: NSArrayController!
    @IBOutlet weak var acTextbooks: NSArrayController!
    @IBOutlet weak var acUnits: NSArrayController!
    @IBOutlet weak var acParts: NSArrayController!
    @IBOutlet weak var tfUnitsInAllFrom: NSTextField!
    @IBOutlet weak var tfUnitsInAllTo: NSTextField!
    @IBOutlet weak var pubLanguages: NSPopUpButton!
    @IBOutlet weak var pubDictItems: NSPopUpButton!
    @IBOutlet weak var pubDictsNote: NSPopUpButton!
    @IBOutlet weak var pubTextbooks: NSPopUpButton!
    @IBOutlet weak var pubUnitFrom: NSPopUpButton!
    @IBOutlet weak var pubUnitTo: NSPopUpButton!
    @IBOutlet weak var pubPartFrom: NSPopUpButton!
    @IBOutlet weak var pubPartTo: NSPopUpButton!
    @IBOutlet weak var scToType: NSSegmentedControl!
    @IBOutlet weak var btnPrevious: NSButton!
    @IBOutlet weak var btnNext: NSButton!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.getData().subscribe {
            self.updateLang()
        }.disposed(by: disposeBag)
    }
    
    @IBAction func close(_ sender: AnyObject) {
        let application = NSApplication.shared
        application.stopModal()
        // http://stackoverflow.com/questions/5711367/os-x-how-can-a-nsviewcontroller-find-its-window
        self.view.window?.close()
        for w in NSApplication.shared.windows {
            if let l = w.windowController as? LollyProtocol { l.settingsChanged() }
            if let l = w.contentViewController as? LollyProtocol { l.settingsChanged() }
        }
    }
    
    @IBAction func langSelected(_ sender: AnyObject) {
        vm.setSelectedLangIndex(pubLanguages.indexOfSelectedItem).flatMap {
            self.vm.updateLang()
        }.subscribe {
            self.updateLang()
        }.disposed(by: disposeBag)
    }
    
    @IBAction func dictMeanSelected(_ sender: AnyObject) {
        vm.selectedDictItemIndex = pubDictItems.indexOfSelectedItem
        vm.updateDictItem().subscribe {
            self.updateDictItem()
        }.disposed(by: disposeBag)
    }
    
    @IBAction func dictNoteSelected(_ sender: AnyObject) {
        vm.selectedDictNoteIndex = pubDictsNote.indexOfSelectedItem
        vm.updateDictNote().subscribe {
            self.updateDictItem()
        }.disposed(by: disposeBag)
    }

    @IBAction func textbookSelected(_ sender: AnyObject) {
        vm.selectedTextbookIndex = pubTextbooks.indexOfSelectedItem
        vm.updateTextbook().subscribe {
            self.updateTextbook()
        }.disposed(by: disposeBag)
    }
    
    @IBAction func unitFromSelected(_ sender: AnyObject) {
        guard updateUnitFrom(v: pubUnitFrom.indexOfSelectedItem + 1) else {return}
        if scToType.selectedSegment == 0 {
            updateSingleUnit()
        } else if scToType.selectedSegment == 1 || vm.isInvalidUnitPart {
            updateUnitPartTo()
        }
    }
    
    @IBAction func partFromSelected(_ sender: AnyObject) {
        guard updatePartFrom(v: pubPartFrom.indexOfSelectedItem + 1) else {return}
        if scToType.selectedSegment == 1 || vm.isInvalidUnitPart { updateUnitPartTo() }
    }
    
    @IBAction func scToTypeClicked(_ sender: AnyObject) {
        let b = scToType.selectedSegment == 2
        pubUnitTo.isEnabled = b
        pubPartTo.isEnabled = b && !vm.isSinglePart
        btnPrevious.isEnabled = !b
        btnNext.isEnabled = !b
        pubPartFrom.isEnabled = scToType.selectedSegment != 0 && !vm.isSinglePart
        if scToType.selectedSegment == 0 {
            updateSingleUnit()
        } else if scToType.selectedSegment == 1 {
            updateUnitPartTo()
        }
    }

    @IBAction func previousUnitPart(_ sender: AnyObject) {
        if scToType.selectedSegment == 0 {
            if vm.USUNITFROM > 1 {
                _ = updateUnitFrom(v: vm.USUNITFROM - 1)
                _ = updateUnitTo(v: vm.USUNITFROM)
            }
        } else if vm.USPARTFROM > 1 {
            _ = updatePartFrom(v: vm.USPARTFROM - 1)
            _ = updateUnitPartTo()
        } else if vm.USUNITFROM > 1 {
            _ = updateUnitFrom(v: vm.USUNITFROM - 1)
            _ = updatePartFrom(v: vm.partCount)
            updateUnitPartTo()
        }
    }

    @IBAction func nextUnitPart(_ sender: AnyObject) {
        if scToType.selectedSegment == 0 {
            if vm.USUNITFROM < vm.unitCount {
                _ = updateUnitFrom(v: vm.USUNITFROM + 1)
                _ = updateUnitTo(v: vm.USUNITFROM)
            }
        } else if vm.USPARTFROM < vm.partCount {
            _ = updatePartFrom(v: vm.USPARTFROM + 1)
            _ = updateUnitPartTo()
        } else if vm.USUNITFROM < vm.unitCount {
            _ = updateUnitFrom(v: vm.USUNITFROM + 1)
            _ = updatePartFrom(v: 1)
            updateUnitPartTo()
        }
    }

    @IBAction func unitToSelected(_ sender: AnyObject) {
        guard updateUnitTo(v: pubUnitTo.indexOfSelectedItem + 1) else {return}
        if vm.isInvalidUnitPart {self.updateUnitPartFrom()}
    }
    
    @IBAction func partToSelected(_ sender: AnyObject) {
        guard updatePartTo(v: pubPartTo.indexOfSelectedItem + 1) else {return}
        vm.updatePartTo().subscribe().disposed(by: disposeBag)
    }

    func updateLang() {
        acLanguages.content = vm.arrLanguages
        updateDictItem()
        updateDictNote()
        updateTextbook()
    }
    
    func updateDictItem() {
        acDictItems.content = vm.arrDictItems
    }
    
    func updateDictNote() {
        acDictsNote.content = vm.arrDictsNote
    }

    func updateTextbook() {
        acTextbooks.content = vm.arrTextbooks
        let unitsInAll = "(\(vm.unitCount) in all)"
        tfUnitsInAllFrom.stringValue = unitsInAll
        tfUnitsInAllTo.stringValue = unitsInAll
        acUnits.content = vm.arrUnits
        acParts.content = vm.arrParts
        pubUnitFrom.selectItem(at: vm.USUNITFROM - 1)
        pubUnitTo.selectItem(at: vm.USUNITTO - 1)
        pubPartFrom.selectItem(at: vm.USPARTFROM - 1)
        pubPartTo.selectItem(at: vm.USPARTTO - 1)
        scToType.selectedSegment = vm.isSingleUnit ? 0 : vm.isSingleUnitPart ? 1 : 2
        scToTypeClicked(self)
    }
    
    private func updateUnitPartFrom() {
        _ = updateUnitFrom(v: vm.USUNITTO)
        _ = updatePartFrom(v: vm.USPARTTO)
    }
    
    private func updateUnitPartTo() {
        _ = updateUnitTo(v: vm.USUNITFROM)
        _ = updatePartTo(v: vm.USPARTFROM)
    }
    
    private func updateSingleUnit() {
        _ = updateUnitTo(v: vm.USUNITFROM)
        _ = updatePartFrom(v: 1)
        _ = updatePartTo(v: vm.partCount)
    }
    
    private func updateUnitFrom(v: Int) -> Bool {
        guard vm.USUNITFROM != v else { return false }
        vm.USUNITFROM = v
        pubUnitFrom.selectItem(at: v - 1)
        vm.updateUnitFrom().subscribe().disposed(by: disposeBag)
        return true
    }
    
    private func updateUnitTo(v: Int) -> Bool {
        guard vm.USUNITTO != v else { return false }
        vm.USUNITTO = v
        pubUnitTo.selectItem(at: v - 1)
        vm.updateUnitTo().subscribe().disposed(by: disposeBag)
        return true
    }
    
    private func updatePartFrom(v: Int) -> Bool {
        guard vm.USPARTFROM != v else { return false }
        vm.USPARTFROM = v
        pubPartFrom.selectItem(at: v - 1)
        vm.updatePartFrom().subscribe().disposed(by: disposeBag)
        return true
    }
    
    private func updatePartTo(v: Int) -> Bool {
        guard vm.USPARTTO != v else { return false }
        vm.USPARTTO = v
        pubPartTo.selectItem(at: v - 1)
        vm.updatePartTo().subscribe().disposed(by: disposeBag)
        return true
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }

}
