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

class SettingsViewController: UITableViewController {
    @IBOutlet weak var langCell: UITableViewCell!
    @IBOutlet weak var voiceCell: UITableViewCell!
    @IBOutlet weak var dictItemCell: UITableViewCell!
    @IBOutlet weak var dictNoteCell: UITableViewCell!
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
    let ddDictItem = DropDown()
    let ddDictNote = DropDown()
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
        vm.getData().subscribe {
            self.updateLang()
        }.disposed(by: disposeBag)

        ddLang.anchorView = langCell
        ddLang.dataSource = vm.arrLanguages.map { $0.LANGNAME }
        ddLang.selectRow(vm.selectedLangIndex)
        ddLang.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectedLangIndex else {return}
            self.vm.setSelectedLang(self.vm.arrLanguages[index]).flatMap {
                self.vm.updateLang()
            }.subscribe {
                self.updateLang()
            }.disposed(by: self.disposeBag)
        }

        ddVoice.anchorView = voiceCell
        ddVoice.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectediOSVoiceIndex else {return}
            self.vm.selectediOSVoice = self.vm.arriOSVoices[index]
            self.vm.updateiOSVoice().subscribe {
                self.updateVoice()
            }.disposed(by: self.disposeBag)
        }

        ddDictItem.anchorView = dictItemCell
        ddDictItem.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectedDictItemIndex else {return}
            self.vm.selectedDictItem = self.vm.arrDictItems[index]
            self.vm.updateDictItem().subscribe {
                self.updateDictItem()
            }.disposed(by: self.disposeBag)
        }

        ddDictNote.anchorView = dictNoteCell
        ddDictNote.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectedDictNoteIndex else {return}
            self.vm.selectedDictNote = self.vm.arrDictsNote[index]
            self.vm.updateDictNote().subscribe {
                self.updateDictNote()
            }.disposed(by: self.disposeBag)
        }

        ddTextbook.anchorView = textbookCell
        ddTextbook.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectedTextbookIndex else {return}
            self.vm.selectedTextbook = self.vm.arrTextbooks[index]
            self.vm.updateTextbook().subscribe {
                self.updateTextbook()
            }.disposed(by: self.disposeBag)
        }

        ddUnitFrom.anchorView = unitFromCell
        ddUnitFrom.selectionAction = { [unowned self] (index: Int, item: String) in
            guard self.updateUnitFrom(v: self.vm.arrUnits[index].value) else {return}
            if self.ddToType.indexForSelectedRow == 0 {
                self.updateSingleUnit()
            } else if self.ddToType.indexForSelectedRow == 1 || self.vm.isInvalidUnitPart {
                self.updateUnitPartTo()
            }
        }

        ddPartFrom.anchorView = partFromCell
        ddPartFrom.selectionAction = { [unowned self] (index: Int, item: String) in
            guard self.updatePartFrom(v: self.vm.arrParts[index].value) else {return}
            if self.ddToType.indexForSelectedRow == 1 || self.vm.isInvalidUnitPart { self.updateUnitPartTo() }
        }
        
        ddToType.dataSource = vm.arrToTypes
        ddToType.anchorView = btnToType
        ddToType.selectionAction = { [unowned self] (index: Int, item: String) in
            self.vm.toType = index
            self.btnToType.titleLabel?.text = item
            let b = index == 2
            self.lblUnitTo.isEnabled = b
            self.lblPartTo.isEnabled = b && !self.vm.isSinglePart
            self.lblUnitToTitle.isEnabled = b
            self.lblPartToTitle.isEnabled = b && !self.vm.isSinglePart
            self.btnPrevious.isEnabled = !b
            self.btnNext.isEnabled = !b
            let b2 = index != 0
            self.lblPartFrom.isEnabled = b2 && !self.vm.isSinglePart
            self.lblPartFromTitle.isEnabled = b2 && !self.vm.isSinglePart
            if index == 0 {
                self.updateSingleUnit()
            } else if index == 1 {
                self.updateUnitPartTo()
            }
        }
        ddToType.cancelAction = {
            // Why do we need this?
            self.btnToType.titleLabel?.text = self.ddToType.selectedItem
        }

        ddUnitTo.anchorView = unitToCell
        ddUnitTo.selectionAction = { [unowned self] (index: Int, item: String) in
            guard self.updateUnitTo(v: self.vm.arrUnits[index].value) else {return}
            if self.vm.isInvalidUnitPart {self.updateUnitPartFrom()}
        }

        ddPartTo.anchorView = partToCell
        ddPartTo.selectionAction = { [unowned self] (index: Int, item: String) in
            guard self.updatePartTo(v: self.vm.arrParts[index].value) else {return}
            if self.vm.isInvalidUnitPart {self.updateUnitPartFrom()}
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            ddLang.show()
        case 1:
            ddVoice.show()
        case 2:
            ddDictItem.show()
        case 3:
            ddDictNote.show()
        case 4:
            ddTextbook.show()
        default:
            switch indexPath.row {
            case 0:
                ddUnitFrom.show()
            case 1 where ddToType.indexForSelectedRow != 0:
                ddPartFrom.show()
            case 3 where ddToType.indexForSelectedRow == 2:
                ddUnitTo.show()
            case 4 where ddToType.indexForSelectedRow == 2:
                ddPartTo.show()
            default:
                break
            }
        }
    }
    
    func updateLang() {
        let item = vm.selectedLang!
        langCell.textLabel!.text = item.LANGNAME
        updateVoice()
        updateDictItem()
        updateDictNote()
        updateTextbook()
    }
    
    func updateVoice() {
        let item = vm.selectediOSVoice
        voiceCell.textLabel!.text = item.VOICENAME
        voiceCell.detailTextLabel!.text = item.VOICELANG
        ddVoice.dataSource = vm.arriOSVoices.map { $0.VOICENAME }
        ddVoice.selectRow(vm.selectediOSVoiceIndex)
    }
    
    func updateDictItem() {
        let item = vm.selectedDictItem!
        dictItemCell.textLabel!.text = item.DICTNAME
        let item2 = vmSettings.arrDictsMean.first { $0.DICTNAME == item.DICTNAME }
        dictItemCell.detailTextLabel!.text = item2?.URL ?? ""
        ddDictItem.dataSource = vm.arrDictItems.map { $0.DICTNAME }
        ddDictItem.selectRow(vm.selectedDictItemIndex)
    }
    
    func updateDictNote() {
        if vm.arrDictsNote.isEmpty {
            // if the label text is set to an empty string,
            // it will remain to be empty and can no longer be changed. (why ?)
            dictNoteCell.textLabel!.text = " "
            dictNoteCell.detailTextLabel!.text = " "
            ddDictNote.dataSource = []
        } else {
            let item = vm.selectedDictNote
            dictNoteCell.textLabel!.text = item.DICTNAME
            dictNoteCell.detailTextLabel!.text = item.URL ?? ""
            dictNoteCell.setNeedsDisplay()
            ddDictNote.dataSource = vm.arrDictsNote.map { $0.DICTNAME }
            ddDictNote.selectRow(vm.selectedDictNoteIndex)
        }
    }

    func updateTextbook() {
        let item = vm.selectedTextbook!
        textbookCell.textLabel!.text = item.TEXTBOOKNAME
        textbookCell.detailTextLabel!.text = "\(vm.unitCount) Units"
        ddTextbook.dataSource = vm.arrTextbooks.map { $0.TEXTBOOKNAME }
        ddTextbook.selectRow(vm.selectedTextbookIndex)
        ddToType.selectRow(vm.toType)
        ddToType.selectionAction!(ddToType.indexForSelectedRow!, ddToType.selectedItem!)
        ddUnitFrom.dataSource = vm.arrUnits.map { $0.label }
        ddUnitFrom.selectRow(vm.arrUnits.firstIndex { $0.value == vm.USUNITFROM }!)
        ddPartFrom.dataSource = vm.arrParts.map { $0.label }
        ddPartFrom.selectRow(vm.arrUnits.firstIndex { $0.value == vm.USPARTFROM }!)
        ddUnitTo.dataSource = vm.arrUnits.map { $0.label }
        ddUnitTo.selectRow(vm.arrUnits.firstIndex { $0.value == vm.USUNITTO }!)
        ddPartTo.dataSource = vm.arrParts.map { $0.label }
        ddPartTo.selectRow(vm.arrUnits.firstIndex { $0.value == vm.USPARTTO }!)
        lblUnitFrom.text = ddUnitFrom.selectedItem
        lblUnitTo.text = ddUnitTo.selectedItem
        lblPartFrom.text = ddPartFrom.selectedItem
        lblPartTo.text = ddPartTo.selectedItem
    }
    
    @IBAction func showToTypeDropDown(_ sender: AnyObject) {
        ddToType.show()
    }

    @IBAction func previousUnitPart(_ sender: AnyObject) {
        if ddToType.indexForSelectedRow == 0 {
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
        if ddToType.indexForSelectedRow == 0 {
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
        ddUnitFrom.selectIndex(vm.arrUnits.firstIndex{ $0.value == v }!)
        lblUnitFrom.text = self.ddUnitFrom.selectedItem
        vm.updateUnitFrom().subscribe().disposed(by: disposeBag)
        return true
    }
    
    private func updatePartFrom(v: Int) -> Bool {
        guard vm.USPARTFROM != v else { return false }
        vm.USPARTFROM = v
        ddPartFrom.selectIndex(vm.arrParts.firstIndex{ $0.value == v }!)
        lblPartFrom.text = self.ddPartFrom.selectedItem
        vm.updatePartFrom().subscribe().disposed(by: disposeBag)
        return true
    }

    private func updateUnitTo(v: Int) -> Bool {
        guard vm.USUNITTO != v else { return false }
        vm.USUNITTO = v
        ddUnitTo.selectIndex(vm.arrUnits.firstIndex{ $0.value == v }!)
        lblUnitTo.text = self.ddUnitTo.selectedItem
        vm.updateUnitTo().subscribe().disposed(by: disposeBag)
        return true
    }
    
    private func updatePartTo(v: Int) -> Bool {
        guard vm.USPARTTO != v else { return false }
        vm.USPARTTO = v
        ddPartTo.selectIndex(vm.arrParts.firstIndex{ $0.value == v }!)
        lblPartTo.text = self.ddPartTo.selectedItem
        vm.updatePartTo().subscribe().disposed(by: disposeBag)
        return true
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }

}
