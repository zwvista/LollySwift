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
class SettingsViewController: NSViewController, SettingsViewModelDelegate {
    @IBOutlet weak var acLanguages: NSArrayController!
    @IBOutlet weak var acVoices: NSArrayController!
    @IBOutlet weak var acDictItems: NSArrayController!
    @IBOutlet weak var acDictsNote: NSArrayController!
    @IBOutlet weak var acDictsTranslation: NSArrayController!
    @IBOutlet weak var acTextbooks: NSArrayController!
    @IBOutlet weak var acUnits: NSArrayController!
    @IBOutlet weak var acParts: NSArrayController!
    @IBOutlet weak var tfUnitsInAllFrom: NSTextField!
    @IBOutlet weak var tfUnitsInAllTo: NSTextField!
    @IBOutlet weak var pubLanguages: NSPopUpButton!
    @IBOutlet weak var pubDictItems: NSPopUpButton!
    @IBOutlet weak var pubDictsNote: NSPopUpButton!
    @IBOutlet weak var pubDictsTranslation: NSPopUpButton!
    @IBOutlet weak var pubTextbookFilters: NSPopUpButton!
    @IBOutlet weak var pubUnitFrom: NSPopUpButton!
    @IBOutlet weak var pubUnitTo: NSPopUpButton!
    @IBOutlet weak var pubPartFrom: NSPopUpButton!
    @IBOutlet weak var pubPartTo: NSPopUpButton!
    @IBOutlet weak var scToType: NSSegmentedControl!
    @IBOutlet weak var btnPrevious: NSButton!
    @IBOutlet weak var btnNext: NSButton!
    @IBOutlet weak var btnApplyAll: NSButton!
    @IBOutlet weak var btnApplyCurrent: NSButton!
    @IBOutlet weak var btnApplyNone: NSButton!

    var vm: SettingsViewModel {
        return AppDelegate.theSettingsViewModel
    }

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.delegate = self
        vm.getData().subscribe().disposed(by: disposeBag)
    }
    
    @IBAction func close(_ sender: AnyObject) {
        let app = NSApplication.shared
        app.stopModal()
        // http://stackoverflow.com/questions/5711367/os-x-how-can-a-nsviewcontroller-find-its-window
        self.view.window?.close()
        guard sender !== btnApplyNone else {return}
        app.enumerateWindows(options: .orderedFrontToBack) { w, b in
            if let l = w.contentViewController as? LollyProtocol { l.settingsChanged() }
            if let l = w.windowController as? LollyProtocol { l.settingsChanged() }
            if sender === btnApplyCurrent { b.pointee = true }
        }
    }
    
    @IBAction func langSelected(_ sender: AnyObject) {
        vm.setSelectedLang(vm.selectedLang).subscribe().disposed(by: disposeBag)
    }
    
    @IBAction func voiceSelected(_ sender: AnyObject) {
        vm.updateMacVoice().subscribe().disposed(by: disposeBag)
    }

    @IBAction func dictReferenceSelected(_ sender: AnyObject) {
        vm.updateDictItem().subscribe().disposed(by: disposeBag)
    }
    
    @IBAction func dictNoteSelected(_ sender: AnyObject) {
        vm.updateDictNote().subscribe().disposed(by: disposeBag)
    }
    
    @IBAction func dictTranslationSelected(_ sender: AnyObject) {
        vm.updateDictTranslation().subscribe().disposed(by: disposeBag)
    }

    @IBAction func textbookSelected(_ sender: AnyObject) {
        vm.updateTextbook().subscribe().disposed(by: disposeBag)
    }
    
    @IBAction func unitFromSelected(_ sender: AnyObject) {
        vm.updateUnitFrom().subscribe().disposed(by: disposeBag)
    }
    
    @IBAction func partFromSelected(_ sender: AnyObject) {
        vm.updatePartFrom().subscribe().disposed(by: disposeBag)
    }
    
    @IBAction func scToTypeClicked(_ sender: AnyObject) {
        vm.toType = UnitPartToType(rawValue: scToType.selectedSegment)!
        let b = vm.toType == .part
        pubUnitTo.isEnabled = b
        pubPartTo.isEnabled = b && !vm.isSinglePart
        btnPrevious.isEnabled = !b
        btnNext.isEnabled = !b
        let t = vm.toType == .unit ? "Unit" : "Part"
        btnPrevious.title = "Previous " + t
        btnNext.title = "Next " + t
        pubPartFrom.isEnabled = vm.toType != .unit && !vm.isSinglePart
        vm.updateToType().subscribe().disposed(by: disposeBag)
    }

    @IBAction func previousUnitPart(_ sender: AnyObject) {
        vm.previousUnitPart().subscribe().disposed(by: disposeBag)
    }

    @IBAction func nextUnitPart(_ sender: AnyObject) {
        vm.nextUnitPart().subscribe().disposed(by: disposeBag)
    }

    @IBAction func unitToSelected(_ sender: AnyObject) {
        vm.updateUnitTo().subscribe().disposed(by: disposeBag)
    }
    
    @IBAction func partToSelected(_ sender: AnyObject) {
        vm.updatePartTo().subscribe().disposed(by: disposeBag)
    }
    
    func onGetData() {
        acLanguages.content = vm.arrLanguages
    }

    func onUpdateLang() {
        acVoices.content = vm.arrMacVoices
        acDictItems.content = vm.arrDictItems
        acDictsNote.content = vm.arrDictsNote
        acDictsTranslation.content = vm.arrDictsTranslation
        acTextbooks.content = vm.arrTextbooks
        onUpdateTextbook()
    }
    
    func onUpdateTextbook() {
        acUnits.content = vm.arrUnits
        acParts.content = vm.arrParts
        scToType.selectedSegment = vm.toType.rawValue
        scToType.performClick(self)
    }
    
    func onUpdateUnitFrom() {
        pubUnitFrom.selectItem(at: vm.arrUnits.firstIndex{ $0.value == vm.USUNITFROM }!)
    }
    
    func onUpdatePartFrom() {
        pubPartFrom.selectItem(at: vm.arrParts.firstIndex{ $0.value == vm.USPARTFROM }!)
    }
    
    func onUpdateUnitTo() {
        pubUnitTo.selectItem(at: vm.arrUnits.firstIndex{ $0.value == vm.USUNITTO }!)
    }
    
    func onUpdatePartTo() {
        pubPartTo.selectItem(at: vm.arrParts.firstIndex{ $0.value == vm.USPARTTO }!)
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }

}
