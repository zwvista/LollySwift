//
//  SettingsViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/16.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import DropDown
import RxSwift

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
    
    var vm: SettingsViewModel {
        return vmSettings
    }
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.delegate = self
        vm.getData().subscribe().disposed(by: disposeBag)

        ddLang.anchorView = langCell
        ddLang.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectedLangIndex else {return}
            self.vm.setSelectedLang(self.vm.arrLanguages[index]).subscribe().disposed(by: self.disposeBag)
        }

        ddVoice.anchorView = voiceCell
        ddVoice.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectediOSVoiceIndex else {return}
            self.vm.selectediOSVoice = self.vm.arriOSVoices[index]
            self.vm.updateiOSVoice().subscribe().disposed(by: self.disposeBag)
        }

        ddDictReference.anchorView = dictItemCell
        ddDictReference.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectedDictReferenceIndex else {return}
            self.vm.selectedDictReference = self.vm.arrDictsReference[index]
            self.vm.updateDictReference().subscribe().disposed(by: self.disposeBag)
        }

        ddDictNote.anchorView = dictNoteCell
        ddDictNote.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectedDictNoteIndex else {return}
            self.vm.selectedDictNote = self.vm.arrDictsNote[index]
            self.vm.updateDictNote().subscribe().disposed(by: self.disposeBag)
        }

        ddDictTranslation.anchorView = dictTranslationCell
        ddDictTranslation.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectedDictTranslationIndex else {return}
            self.vm.selectedDictTranslation = self.vm.arrDictsTranslation[index]
            self.vm.updateDictTranslation().subscribe().disposed(by: self.disposeBag)
        }

        ddTextbook.anchorView = textbookCell
        ddTextbook.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectedTextbookIndex else {return}
            self.vm.selectedTextbook = self.vm.arrTextbooks[index]
            self.vm.updateTextbook().subscribe().disposed(by: self.disposeBag)
        }

        ddUnitFrom.anchorView = unitFromCell
        ddUnitFrom.selectionAction = { [unowned self] (index: Int, item: String) in
            self.vm.USUNITFROM = self.vm.arrUnits[index].value
            self.vm.updateUnitFrom().subscribe().disposed(by: self.disposeBag)
        }

        ddPartFrom.anchorView = partFromCell
        ddPartFrom.selectionAction = { [unowned self] (index: Int, item: String) in
            self.vm.USPARTFROM = self.vm.arrParts[index].value
            self.vm.updatePartFrom().subscribe().disposed(by: self.disposeBag)
        }
        
        ddToType.dataSource = vm.arrToTypes
        ddToType.anchorView = btnToType
        ddToType.selectionAction = { [unowned self] (index: Int, item: String) in
            self.vm.toType = UnitPartToType(rawValue: index)!
            self.btnToType.setTitle(item, for: .normal)
            let b = self.vm.toType == .to
            self.lblUnitTo.isEnabled = b
            self.lblUnitToTitle.isEnabled = self.lblUnitTo.isEnabled
            self.lblPartTo.isEnabled = b && !self.vm.isSinglePart
            self.lblPartToTitle.isEnabled = self.lblPartTo.isEnabled
            self.btnPrevious.isEnabled = !b
            self.btnNext.isEnabled = !b
            let b2 = self.vm.toType != .unit
            self.lblPartFrom.isEnabled = b2 && !self.vm.isSinglePart
            self.lblPartFromTitle.isEnabled = self.lblPartFrom.isEnabled
            self.vm.updateToType().subscribe().disposed(by: self.disposeBag)
        }

        ddUnitTo.anchorView = unitToCell
        ddUnitTo.selectionAction = { [unowned self] (index: Int, item: String) in
            self.vm.USUNITTO = self.vm.arrUnits[index].value
            self.vm.updateUnitTo().subscribe().disposed(by: self.disposeBag)
        }

        ddPartTo.anchorView = partToCell
        ddPartTo.selectionAction = { [unowned self] (index: Int, item: String) in
            self.vm.USPARTTO = self.vm.arrParts[index].value
            self.vm.updatePartTo().subscribe().disposed(by: self.disposeBag)
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
            case 1 where vm.toType != .unit:
                ddPartFrom.show()
            case 3 where vm.toType == .to:
                ddUnitTo.show()
            case 4 where vm.toType == .to:
                ddPartTo.show()
            default:
                break
            }
        }
    }
    
    func onGetData() {
        ddLang.dataSource = vm.arrLanguages.map { $0.LANGNAME }
    }
    
    func onUpdateLang() {
        let item = vm.selectedLang!
        langCell.textLabel!.text = item.LANGNAME
        ddLang.selectIndex(vm.selectedLangIndex)

        ddVoice.dataSource = vm.arriOSVoices.map { $0.VOICENAME }
        onUpdateiOSVoice()
        
        ddDictReference.dataSource = vm.arrDictsReference.map { $0.DICTNAME }
        onUpdateDictReference()

        ddDictNote.dataSource = vm.arrDictsNote.isEmpty ? [] : vm.arrDictsNote.map { $0.DICTNAME }
        onUpdateDictNote()

        ddDictTranslation.dataSource = vm.arrDictsTranslation.isEmpty ? [] : vm.arrDictsTranslation.map { $0.DICTNAME }
        onUpdateDictTranslation()

        ddTextbook.dataSource = vm.arrTextbooks.map { $0.TEXTBOOKNAME }
        onUpdateTextbook()
    }
    
    func onUpdateiOSVoice() {
        let item = vm.selectediOSVoice
        voiceCell.textLabel!.text = item.VOICENAME
        voiceCell.detailTextLabel!.text = item.VOICELANG
        ddVoice.selectIndex(vm.selectediOSVoiceIndex)
    }
    
    func onUpdateDictReference() {
        let item = vm.selectedDictReference!
        dictItemCell.textLabel!.text = item.DICTNAME
        let item2 = vm.arrDictsReference.first { $0.DICTNAME == item.DICTNAME }
        dictItemCell.detailTextLabel!.text = item2?.URL ?? ""
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
            dictNoteCell.detailTextLabel!.text = item.URL ?? ""
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
            dictTranslationCell.detailTextLabel!.text = item.URL ?? ""
        }
        ddDictTranslation.selectIndex(vm.selectedDictTranslationIndex)
    }

    func onUpdateTextbook() {
        let item = vm.selectedTextbook!
        textbookCell.textLabel!.text = item.TEXTBOOKNAME
        textbookCell.detailTextLabel!.text = "\(vm.unitCount) Units"
        ddTextbook.selectIndex(vm.selectedTextbookIndex)
        ddToType.selectIndex(vm.toType.rawValue)
        ddToType.selectionAction!(vm.toType.rawValue, ddToType.selectedItem!)
        ddUnitFrom.dataSource = vm.arrUnits.map { $0.label }
        onUpdateUnitFrom()
        ddPartFrom.dataSource = vm.arrParts.map { $0.label }
        onUpdatePartFrom()
        ddUnitTo.dataSource = vm.arrUnits.map { $0.label }
        onUpdateUnitTo()
        ddPartTo.dataSource = vm.arrParts.map { $0.label }
        onUpdatePartTo()
    }
    
    @IBAction func showToTypeDropDown(_ sender: AnyObject) {
        ddToType.show()
    }

    @IBAction func previousUnitPart(_ sender: AnyObject) {
        vm.previousUnitPart().subscribe().disposed(by: disposeBag)
    }
    
    @IBAction func nextUnitPart(_ sender: AnyObject) {
        vm.nextUnitPart().subscribe().disposed(by: disposeBag)
    }

    func onUpdateUnitFrom() {
        ddUnitFrom.selectIndex(vm.arrUnits.firstIndex { $0.value == vm.USUNITFROM }!)
        lblUnitFrom.text = ddUnitFrom.selectedItem
    }
    
    func onUpdatePartFrom() {
        ddPartFrom.selectIndex(vm.arrParts.firstIndex { $0.value == vm.USPARTFROM }!)
        lblPartFrom.text = ddPartFrom.selectedItem
    }

    func onUpdateUnitTo() {
        ddUnitTo.selectIndex(vm.arrUnits.firstIndex { $0.value == vm.USUNITTO }!)
        lblUnitTo.text = ddUnitTo.selectedItem
    }
    
    func onUpdatePartTo() {
        ddPartTo.selectIndex(vm.arrParts.firstIndex { $0.value == vm.USPARTTO }!)
        lblPartTo.text = ddPartTo.selectedItem
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }

}
