//
//  SettingsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/23.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import Combine

@objcMembers
class SettingsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

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

    var vm: SettingsViewModel { AppDelegate.theSettingsViewModel }
    var subscriptions = Set<AnyCancellable>()
    var complete: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        vm.$arrLanguages.didSet.sink { [unowned self] _ in
            acLanguages.content = vm.arrLanguages
        } ~ subscriptions

        vm.$selectedDictsReferenceIndexes.didSet.sink { [unowned self] n in
            tvDictsReference.reloadData()
        } ~ subscriptions

        vm.$arrMacVoices.didSet.sink { [unowned self] _ in
            acVoices.content = vm.arrMacVoices
        } ~ subscriptions

        vm.$arrDictsNote.didSet.sink { [unowned self] _ in
            acDictsNote.content = vm.arrDictsNote
        } ~ subscriptions

        vm.$arrDictsTranslation.didSet.sink { [unowned self] _ in
            acDictsTranslation.content = vm.arrDictsTranslation
        } ~ subscriptions

        vm.$arrTextbooks.didSet.sink { [unowned self] _ in
            acTextbooks.content = vm.arrTextbooks
        } ~ subscriptions

        vm.$selectedTextbookIndex.didSet.sink { [unowned self] _ in
            acUnits.content = vm.arrUnits
            acParts.content = vm.arrParts
            tfUnitsInAllFrom.stringValue = vm.unitsInAll
            tfUnitsInAllTo.stringValue = vm.unitsInAll
        } ~ subscriptions

        vm.$selectedLangIndex <~> pubLanguages.selectedItemIndexProperty ~ subscriptions
        vm.$selectedMacVoiceIndex <~> pubVoices.selectedItemIndexProperty ~ subscriptions
        vm.$selectedDictNoteIndex <~> pubDictsNote.selectedItemIndexProperty ~ subscriptions
        vm.$selectedDictTranslationIndex <~> pubDictsTranslation.selectedItemIndexProperty ~ subscriptions
        vm.$selectedTextbookIndex <~> pubTextbooks.selectedItemIndexProperty ~ subscriptions
        vm.$selectedUnitFromIndex <~> pubUnitFrom.selectedItemIndexProperty ~ subscriptions
        vm.$selectedPartFromIndex <~> pubPartFrom.selectedItemIndexProperty ~ subscriptions
        vm.$selectedUnitToIndex <~> pubUnitTo.selectedItemIndexProperty ~ subscriptions
        vm.$selectedPartToIndex <~> pubPartTo.selectedItemIndexProperty ~ subscriptions
        vm.$toType_ <~> scToType.selectedSegmentProperty ~ subscriptions
        vm.$unitToEnabled ~> (pubUnitTo, \.isEnabled) ~ subscriptions
        vm.$partToEnabled ~> (pubPartTo, \.isEnabled) ~ subscriptions
        vm.$previousEnabled ~> (btnPrevious, \.isEnabled) ~ subscriptions
        vm.$nextEnabled ~> (btnNext, \.isEnabled) ~ subscriptions
        vm.$previousTitle ~> (btnPrevious, \.title) ~ subscriptions
        vm.$nextTitle ~> (btnNext, \.title) ~ subscriptions
        vm.$partFromEnabled ~> (pubPartFrom, \.isEnabled) ~ subscriptions

        Task {
            await vm.getData()
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = "Settings"
    }
    
    override func viewDidDisappear() {
        complete?()
    }

    @IBAction func previousUnitPart(_ sender: AnyObject) {
        Task {
            await vm.previousUnitPart()
        }
    }

    @IBAction func nextUnitPart(_ sender: AnyObject) {
        Task {
            await vm.nextUnitPart()
        }
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
        dictVC.complete = { [unowned self] in
            tvDictsReference.reloadData()
        }
        presentAsModalWindow(dictVC)
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }

}
