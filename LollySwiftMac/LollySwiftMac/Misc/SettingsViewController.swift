//
//  SettingsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/23.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import NSObject_Rx

@objcMembers
class SettingsViewController: NSViewController, SettingsViewModelDelegate, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var acLanguages: NSArrayController!
    @IBOutlet weak var acVoices: NSArrayController!
    @IBOutlet weak var acDictsNote: NSArrayController!
    @IBOutlet weak var acDictsTranslation: NSArrayController!
    @IBOutlet weak var acTextbooks: NSArrayController!
    @IBOutlet weak var acUnits: NSArrayController!
    @IBOutlet weak var acParts: NSArrayController!
    @IBOutlet weak var tfUnitsInAllFrom: NSTextField!
    @IBOutlet weak var tfUnitsInAllTo: NSTextField!
    @IBOutlet weak var pubLanguages: NSPopUpButton!
    @IBOutlet weak var tvDictsReference: NSTableView!
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

    var vm: SettingsViewModel { AppDelegate.theSettingsViewModel }

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.delegate = self
        vm.getData().subscribe() ~ rx.disposeBag
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
        vm.setSelectedLang(vm.selectedLang).subscribe() ~ rx.disposeBag
    }
    
    @IBAction func voiceSelected(_ sender: AnyObject) {
        vm.updateMacVoice().subscribe() ~ rx.disposeBag
    }
    
    @IBAction func dictNoteSelected(_ sender: AnyObject) {
        vm.updateDictNote().subscribe() ~ rx.disposeBag
    }
    
    @IBAction func dictTranslationSelected(_ sender: AnyObject) {
        vm.updateDictTranslation().subscribe() ~ rx.disposeBag
    }

    @IBAction func textbookSelected(_ sender: AnyObject) {
        vm.updateTextbook().subscribe() ~ rx.disposeBag
    }
    
    @IBAction func unitFromSelected(_ sender: AnyObject) {
        vm.updateUnitFrom().subscribe() ~ rx.disposeBag
    }
    
    @IBAction func partFromSelected(_ sender: AnyObject) {
        vm.updatePartFrom().subscribe() ~ rx.disposeBag
    }
    
    @IBAction func scToTypeClicked(_ sender: AnyObject) {
        vm.toType = UnitPartToType(rawValue: scToType.selectedSegment)!
        let b = vm.toType == .to
        pubUnitTo.isEnabled = b
        pubPartTo.isEnabled = b && !vm.isSinglePart
        btnPrevious.isEnabled = !b
        btnNext.isEnabled = !b
        let b2 = vm.toType != .unit
        let t = !b2 ? "Unit" : "Part"
        btnPrevious.title = "Previous " + t
        btnNext.title = "Next " + t
        pubPartFrom.isEnabled = b2 && !vm.isSinglePart
        vm.updateToType().subscribe() ~ rx.disposeBag
    }

    @IBAction func previousUnitPart(_ sender: AnyObject) {
        vm.previousUnitPart().subscribe() ~ rx.disposeBag
    }

    @IBAction func nextUnitPart(_ sender: AnyObject) {
        vm.nextUnitPart().subscribe() ~ rx.disposeBag
    }

    @IBAction func unitToSelected(_ sender: AnyObject) {
        vm.updateUnitTo().subscribe() ~ rx.disposeBag
    }
    
    @IBAction func partToSelected(_ sender: AnyObject) {
        vm.updatePartTo().subscribe() ~ rx.disposeBag
    }
    
    func onGetData() {
        acLanguages.content = vm.arrLanguages
    }

    func onUpdateLang() {
        acVoices.content = vm.arrMacVoices
        tvDictsReference.reloadData()
        acDictsNote.content = vm.arrDictsNote
        acDictsTranslation.content = vm.arrDictsTranslation
        acTextbooks.content = vm.arrTextbooks
        onUpdateTextbook()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        vm.selectedDictsReference.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let columnName = tableColumn!.identifier.rawValue
        cell.textField?.stringValue = String(describing: vm.selectedDictsReference[row].value(forKey: columnName) ?? "")
        return cell
    }

    @IBAction func selectDicts(_ sender: Any) {
        let dictVC = storyboard!.instantiateController(withIdentifier: "SelectDictsViewController") as! SelectDictsViewController
        dictVC.complete = {
            self.tvDictsReference.reloadData()
        }
        self.presentAsModalWindow(dictVC)
    }
    
    func onUpdateTextbook() {
        acUnits.content = vm.arrUnits
        acParts.content = vm.arrParts
        tfUnitsInAllFrom.stringValue = vm.unitsInAll
        tfUnitsInAllTo.stringValue = vm.unitsInAll
        scToType.selectedSegment = vm.toType.rawValue
        scToType.performClick(self)
    }
    
    func onUpdateUnitFrom() {
        pubUnitFrom.selectItem(at: vm.arrUnits.firstIndex { $0.value == vm.USUNITFROM }!)
    }
    
    func onUpdatePartFrom() {
        pubPartFrom.selectItem(at: vm.arrParts.firstIndex { $0.value == vm.USPARTFROM }!)
    }
    
    func onUpdateUnitTo() {
        pubUnitTo.selectItem(at: vm.arrUnits.firstIndex { $0.value == vm.USUNITTO }!)
    }
    
    func onUpdatePartTo() {
        pubPartTo.selectItem(at: vm.arrParts.firstIndex { $0.value == vm.USPARTTO }!)
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }

}
