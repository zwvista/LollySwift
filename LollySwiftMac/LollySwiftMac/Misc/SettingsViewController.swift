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
    @IBOutlet weak var pubVoices: NSPopUpButton!
    @IBOutlet weak var tvDictsReference: NSTableView!
    @IBOutlet weak var btnSelectDicts: NSButton!
    @IBOutlet weak var pubDictsNote: NSPopUpButton!
    @IBOutlet weak var pubDictsTranslation: NSPopUpButton!
    @IBOutlet weak var pubTextbooks: NSPopUpButton!
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

        _ = vm.selectedLangIndex_ <~> pubLanguages.rx.selectedItemIndex
        _ = vm.selectedMacVoiceIndex_ <~> pubVoices.rx.selectedItemIndex
        _ = vm.selectedDictNoteIndex_ <~> pubDictsNote.rx.selectedItemIndex
        _ = vm.selectedDictTranslationIndex_ <~> pubDictsTranslation.rx.selectedItemIndex
        _ = vm.selectedTextbookIndex_ <~> pubTextbooks.rx.selectedItemIndex
        _ = vm.selectedUnitFromIndex_ <~> pubUnitFrom.rx.selectedItemIndex
        _ = vm.selectedPartFromIndex_ <~> pubPartFrom.rx.selectedItemIndex
        _ = vm.selectedUnitToIndex_ <~> pubUnitTo.rx.selectedItemIndex
        _ = vm.selectedPartToIndex_ <~> pubPartTo.rx.selectedItemIndex
        _ = vm.toType_ <~> scToType.rx.selectedSegment
        _ = vm.unitToEnabled ~> pubUnitTo.rx.isEnabled
        _ = vm.partToEnabled ~> pubPartTo.rx.isEnabled
        _ = vm.previousEnabled ~> btnPrevious.rx.isEnabled
        _ = vm.nextEnabled ~> btnNext.rx.isEnabled
        _ = vm.previousTitle ~> btnPrevious.rx.title
        _ = vm.nextTitle ~> btnNext.rx.title
        _ = vm.partFromEnabled ~> pubPartFrom.rx.isEnabled

        vm.getData().subscribe() ~ rx.disposeBag
    }
    
    @IBAction func close(_ sender: AnyObject) {
        let app = NSApplication.shared
        app.stopModal()
        // http://stackoverflow.com/questions/5711367/os-x-how-can-a-nsviewcontroller-find-its-window
        self.view.window?.close()
        if sender === btnApplyNone {return}
        app.enumerateWindows(options: .orderedFrontToBack) { w, b in
            if let vc = w.contentViewController as? LollyProtocol { vc.settingsChanged() }
            if let wc = w.windowController as? LollyProtocol { wc.settingsChanged() }
            if sender === btnApplyCurrent { b.pointee = true }
        }
    }

    @IBAction func previousUnitPart(_ sender: AnyObject) {
        vm.previousUnitPart().subscribe() ~ rx.disposeBag
    }

    @IBAction func nextUnitPart(_ sender: AnyObject) {
        vm.nextUnitPart().subscribe() ~ rx.disposeBag
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
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }

}
