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
    @IBOutlet weak var acVoices: NSArrayController!
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
            self.acLanguages.content = self.vm.arrLanguages
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
        vm.setSelectedLang(vm.selectedLang).flatMap {
            self.vm.updateLang()
        }.subscribe {
            self.updateLang()
        }.disposed(by: disposeBag)
    }
    
    @IBAction func voiceSelected(_ sender: AnyObject) {
        vm.updateMacVoice().subscribe().disposed(by: disposeBag)
    }

    @IBAction func dictMeanSelected(_ sender: AnyObject) {
        vm.updateDictItem().subscribe().disposed(by: disposeBag)
    }
    
    @IBAction func dictNoteSelected(_ sender: AnyObject) {
        vm.updateDictNote().subscribe().disposed(by: disposeBag)
    }

    @IBAction func textbookSelected(_ sender: AnyObject) {
        vm.updateTextbook().subscribe {
            self.updateTextbook()
        }.disposed(by: disposeBag)
    }
    
    @IBAction func unitFromSelected(_ sender: AnyObject) {
        guard updateUnitFrom(v: vm.arrUnits[pubUnitFrom.indexOfSelectedItem].value, check: false) else {return}
        if vm.toType == 0 {
            updateSingleUnit()
        } else if vm.toType == 1 || vm.isInvalidUnitPart {
            updateUnitPartTo()
        }
    }
    
    @IBAction func partFromSelected(_ sender: AnyObject) {
        guard updatePartFrom(v: vm.arrParts[pubPartFrom.indexOfSelectedItem].value, check: false) else {return}
        if vm.toType == 1 || vm.isInvalidUnitPart { updateUnitPartTo() }
    }
    
    @IBAction func scToTypeClicked(_ sender: AnyObject) {
        let b = vm.toType == 2
        pubUnitTo.isEnabled = b
        pubPartTo.isEnabled = b && !vm.isSinglePart
        btnPrevious.isEnabled = !b
        btnNext.isEnabled = !b
        pubPartFrom.isEnabled = vm.toType != 0 && !vm.isSinglePart
        if vm.toType == 0 {
            updateSingleUnit()
        } else if vm.toType == 1 {
            updateUnitPartTo()
        }
    }

    @IBAction func previousUnitPart(_ sender: AnyObject) {
        if vm.toType == 0 {
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
        if vm.toType == 0 {
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
        guard updateUnitTo(v: vm.arrUnits[pubUnitTo.indexOfSelectedItem].value, check: false) else {return}
        if vm.isInvalidUnitPart {self.updateUnitPartFrom()}
    }
    
    @IBAction func partToSelected(_ sender: AnyObject) {
        guard updatePartTo(v: vm.arrParts[pubPartTo.indexOfSelectedItem].value, check: false) else {return}
        if vm.isInvalidUnitPart {self.updateUnitPartFrom()}
    }

    func updateLang() {
        acVoices.content = vm.arrMacVoices
        acDictItems.content = vm.arrDictItems
        acDictsNote.content = vm.arrDictsNote
        acTextbooks.content = vm.arrTextbooks
        updateTextbook()
    }
    
    func updateTextbook() {
        acUnits.content = vm.arrUnits
        acParts.content = vm.arrParts
        scToType.selectedSegment = vm.toType
        scToType.performClick(self)
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
    
    private func updateUnitFrom(v: Int, check: Bool = true) -> Bool {
        guard !check || vm.USUNITFROM != v else { return false }
        vm.USUNITFROM = v
        pubUnitFrom.selectItem(at: vm.arrUnits.firstIndex{ $0.value == v }!)
        vm.updateUnitFrom().subscribe().disposed(by: disposeBag)
        return true
    }
    
    private func updatePartFrom(v: Int, check: Bool = true) -> Bool {
        guard !check || vm.USPARTFROM != v else { return false }
        vm.USPARTFROM = v
        pubPartFrom.selectItem(at: vm.arrParts.firstIndex{ $0.value == v }!)
        vm.updatePartFrom().subscribe().disposed(by: disposeBag)
        return true
    }

    private func updateUnitTo(v: Int, check: Bool = true) -> Bool {
        guard !check || vm.USUNITTO != v else { return false }
        vm.USUNITTO = v
        pubUnitTo.selectItem(at: vm.arrUnits.firstIndex{ $0.value == v }!)
        vm.updateUnitTo().subscribe().disposed(by: disposeBag)
        return true
    }
    
    private func updatePartTo(v: Int, check: Bool = true) -> Bool {
        guard !check || vm.USPARTTO != v else { return false }
        vm.USPARTTO = v
        pubPartTo.selectItem(at: vm.arrParts.firstIndex{ $0.value == v }!)
        vm.updatePartTo().subscribe().disposed(by: disposeBag)
        return true
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }

}
