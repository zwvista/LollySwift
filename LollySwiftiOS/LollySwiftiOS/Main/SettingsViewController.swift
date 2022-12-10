//
//  SettingsViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/16.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import DropDown
import Combine
import CombineCocoa

class SettingsViewController: UITableViewController, SettingsViewModelDelegate {
    @IBOutlet weak var langCell: UITableViewCell!
    @IBOutlet weak var voiceCell: UITableViewCell!
    @IBOutlet weak var dictItemCell: UITableViewCell!
    @IBOutlet weak var dictNoteCell: UITableViewCell!
    @IBOutlet weak var dictTranslationCell: UITableViewCell!
    @IBOutlet weak var textbookCell: UITableViewCell!
    @IBOutlet weak var unitFromCell: UITableViewCell!
    @IBOutlet weak var partFromCell: UITableViewCell!
    @IBOutlet weak var unitToCell: UITableViewCell!
    @IBOutlet weak var partToCell: UITableViewCell!
    @IBOutlet weak var lblUnitFrom: UILabel!
    @IBOutlet weak var lblUnitTo: UILabel!
    @IBOutlet weak var btnToType: UIButton!
    @IBOutlet weak var lblPartFrom: UILabel!
    @IBOutlet weak var lblPartTo: UILabel!
    @IBOutlet weak var lblUnitFromTitle: UILabel!
    @IBOutlet weak var lblPartFromTitle: UILabel!
    @IBOutlet weak var lblUnitToTitle: UILabel!
    @IBOutlet weak var lblPartToTitle: UILabel!
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var btnNext: UIButton!

    let ddLang = DropDown()
    let ddVoice = DropDown()
    let ddDictReference = DropDown()
    let ddDictNote = DropDown()
    let ddDictTranslation = DropDown()
    let ddTextbook = DropDown()
    let ddUnitFrom = DropDown()
    let ddPartFrom = DropDown()
    let ddUnitTo = DropDown()
    let ddPartTo = DropDown()
    let ddToType = DropDown()

    var vm: SettingsViewModel { vmSettings }
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.delegate = self

        ddLang.anchorView = langCell
        ddLang.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectedLangIndex else {return}
            self.vm.selectedLangIndex = index
        }

        ddVoice.anchorView = voiceCell
        ddVoice.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectediOSVoiceIndex else {return}
            self.vm.selectediOSVoiceIndex = index
        }

        ddDictReference.anchorView = dictItemCell
        ddDictReference.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectedDictReferenceIndex else {return}
            self.vm.selectedDictReferenceIndex = index
        }

        ddDictNote.anchorView = dictNoteCell
        ddDictNote.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectedDictNoteIndex else {return}
            self.vm.selectedDictNoteIndex = index
        }

        ddDictTranslation.anchorView = dictTranslationCell
        ddDictTranslation.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectedDictTranslationIndex else {return}
            self.vm.selectedDictTranslationIndex = index
        }

        ddTextbook.anchorView = textbookCell
        ddTextbook.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectedTextbookIndex else {return}
            self.vm.selectedTextbookIndex = index
        }

        ddUnitFrom.anchorView = unitFromCell
        ddUnitFrom.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectedUnitFromIndex else {return}
            self.vm.selectedUnitFromIndex = index
        }

        ddPartFrom.anchorView = partFromCell
        ddPartFrom.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectedPartFromIndex else {return}
            self.vm.selectedPartFromIndex = index
        }
        
        ddToType.dataSource = SettingsViewModel.arrToTypes
        ddToType.anchorView = btnToType
        ddToType.selectionAction = { [unowned self] (index: Int, item: String) in
            self.vm.toType = UnitPartToType(rawValue: index)!
        }

        ddUnitTo.anchorView = unitToCell
        ddUnitTo.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectedUnitToIndex else {return}
            self.vm.selectedUnitToIndex = index
        }

        ddPartTo.anchorView = partToCell
        ddPartTo.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectedPartToIndex else {return}
            self.vm.selectedPartToIndex = index
        }

        vm.$unitToEnabled ~> (lblUnitTo, \.isEnabled) ~ subscriptions
        vm.$unitToEnabled ~> (lblUnitToTitle, \.isEnabled) ~ subscriptions
        vm.$partToEnabled ~> (lblPartTo, \.isEnabled) ~ subscriptions
        vm.$partToEnabled ~> (lblPartToTitle, \.isEnabled) ~ subscriptions
        vm.$previousEnabled ~> (btnPrevious, \.isEnabled) ~ subscriptions
        vm.$nextEnabled ~> (btnNext, \.isEnabled) ~ subscriptions
        vm.$previousTitle ~> (btnPrevious, \.titleNormal) ~ subscriptions
        vm.$nextTitle ~> (btnNext, \.titleNormal) ~ subscriptions
        vm.$partFromEnabled ~> (lblPartFrom, \.isEnabled) ~ subscriptions
        vm.$partFromEnabled ~> (lblPartFromTitle, \.isEnabled) ~ subscriptions
        vm.$toTypeTitle ~> (btnToType, \.titleNormal) ~ subscriptions

        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        refresh(refreshControl!)
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        Task {
            await vm.getData()
            sender.endRefreshing()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            ddLang.show()
        case 1:
            ddVoice.show()
        case 2:
            ddDictReference.show()
        case 3:
            ddDictNote.show()
        case 4:
            ddDictTranslation.show()
        case 5:
            ddTextbook.show()
        default:
            switch indexPath.row {
            case 0:
                ddUnitFrom.show()
            case 1 where vm.partFromEnabled:
                ddPartFrom.show()
            case 3 where vm.unitToEnabled:
                ddUnitTo.show()
            case 4 where vm.partToEnabled:
                ddPartTo.show()
            default:
                break
            }
        }
    }
    
    func onGetData() {
        ddLang.dataSource = vm.arrLanguages.map(\.LANGNAME)
    }
    
    func onUpdateLang() {
        let item = vm.selectedLang
        langCell.textLabel!.text = item.LANGNAME
        ddLang.selectIndex(vm.selectedLangIndex)

        ddVoice.dataSource = vm.arriOSVoices.map(\.VOICENAME)
        onUpdateiOSVoice()
        
        ddDictReference.dataSource = vm.arrDictsReference.map(\.DICTNAME)
        onUpdateDictReference()

        ddDictNote.dataSource = vm.arrDictsNote.isEmpty ? [] : vm.arrDictsNote.map(\.DICTNAME)
        onUpdateDictNote()

        ddDictTranslation.dataSource = vm.arrDictsTranslation.isEmpty ? [] : vm.arrDictsTranslation.map(\.DICTNAME)
        onUpdateDictTranslation()

        ddTextbook.dataSource = vm.arrTextbooks.map(\.TEXTBOOKNAME)
        onUpdateTextbook()
    }
    
    func onUpdateiOSVoice() {
        let item = vm.selectediOSVoice
        voiceCell.textLabel!.text = item.VOICENAME
        voiceCell.detailTextLabel!.text = item.VOICELANG
        ddVoice.selectIndex(vm.selectediOSVoiceIndex)
    }
    
    func onUpdateDictReference() {
        let item = vm.selectedDictReference
        dictItemCell.textLabel!.text = item.DICTNAME
        dictItemCell.detailTextLabel!.text = item.URL
        ddDictReference.selectIndex(vm.selectedDictReferenceIndex)
    }
    
    func onUpdateDictNote() {
        let item = vm.selectedDictNote
        if item.DICTNAME.isEmpty {
            // if the label text is set to an empty string,
            // it will remain to be empty and can no longer be changed. (why ?)
            dictNoteCell.textLabel!.text = " "
            dictNoteCell.detailTextLabel!.text = " "
        } else {
            dictNoteCell.textLabel!.text = item.DICTNAME
            dictNoteCell.detailTextLabel!.text = item.URL
        }
        ddDictNote.selectIndex(vm.selectedDictNoteIndex)
    }
    
    func onUpdateDictTranslation() {
        let item = vm.selectedDictTranslation
        if item.DICTNAME.isEmpty {
            // if the label text is set to an empty string,
            // it will remain to be empty and can no longer be changed. (why ?)
            dictTranslationCell.textLabel!.text = " "
            dictTranslationCell.detailTextLabel!.text = " "
        } else {
            dictTranslationCell.textLabel!.text = item.DICTNAME
            dictTranslationCell.detailTextLabel!.text = item.URL
        }
        ddDictTranslation.selectIndex(vm.selectedDictTranslationIndex)
    }

    func onUpdateTextbook() {
        let item = vm.selectedTextbook
        textbookCell.textLabel!.text = item.TEXTBOOKNAME
        textbookCell.detailTextLabel!.text = "\(vm.unitCount) Units"
        ddTextbook.selectIndex(vm.selectedTextbookIndex)
        ddToType.selectIndex(vm.toType.rawValue)
        ddToType.selectionAction!(vm.toType.rawValue, ddToType.selectedItem!)
        guard !vm.arrUnits.isEmpty else {return}
        ddUnitFrom.dataSource = vm.arrUnits.map(\.label)
        onUpdateUnitFrom()
        ddPartFrom.dataSource = vm.arrParts.map(\.label)
        onUpdatePartFrom()
        ddUnitTo.dataSource = vm.arrUnits.map(\.label)
        onUpdateUnitTo()
        ddPartTo.dataSource = vm.arrParts.map(\.label)
        onUpdatePartTo()
    }
    
    @IBAction func showToTypeDropDown(_ sender: AnyObject) {
        ddToType.show()
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

    func onUpdateUnitFrom() {
        ddUnitFrom.selectIndex(vm.selectedUnitFromIndex)
        lblUnitFrom.text = ddUnitFrom.selectedItem
    }
    
    func onUpdatePartFrom() {
        ddPartFrom.selectIndex(vm.selectedPartFromIndex)
        lblPartFrom.text = ddPartFrom.selectedItem
    }

    func onUpdateUnitTo() {
        ddUnitTo.selectIndex(vm.selectedUnitToIndex)
        lblUnitTo.text = ddUnitTo.selectedItem
    }
    
    func onUpdatePartTo() {
        ddPartTo.selectIndex(vm.selectedPartToIndex)
        lblPartTo.text = ddPartTo.selectedItem
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }

}
