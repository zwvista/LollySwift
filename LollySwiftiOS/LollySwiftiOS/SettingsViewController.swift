//
//  SettingsViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/16.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import DropDown

class SettingsViewController: UITableViewController {
    @IBOutlet weak var langCell: UITableViewCell!
    @IBOutlet weak var dictOnlineCell: UITableViewCell!
    @IBOutlet weak var dictNoteCell: UITableViewCell!
    @IBOutlet weak var textbookCell: UITableViewCell!
    @IBOutlet weak var unitFromCell: UITableViewCell!
    @IBOutlet weak var partFromCell: UITableViewCell!
    @IBOutlet weak var unitToCell: UITableViewCell!
    @IBOutlet weak var partToCell: UITableViewCell!
    @IBOutlet weak var lblUnitFrom: UILabel!
    @IBOutlet weak var lblUnitTo: UILabel!
    @IBOutlet weak var swUnitPartTo: UISwitch!
    @IBOutlet weak var lblPartFrom: UILabel!
    @IBOutlet weak var lblPartTo: UILabel!
    @IBOutlet weak var lblUnitToTitle: UILabel!
    @IBOutlet weak var lblPartToTitle: UILabel!
    
    let ddLang = DropDown()
    let ddDictOnline = DropDown()
    let ddDictNote = DropDown()
    let ddTextbook = DropDown()
    let ddUnitFrom = DropDown()
    let ddPartFrom = DropDown()
    let ddUnitTo = DropDown()
    let ddPartTo = DropDown()
    
    var vm: SettingsViewModel {
        return vmSettings
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.getData {
            self.updateLang()
        }
        
        ddLang.anchorView = langCell
        ddLang.dataSource = vm.arrLanguages.map { $0.LANGNAME }
        ddLang.selectRow(vm.selectedLangIndex)
        ddLang.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectedLangIndex else {return}
            self.vm.setSelectedLangIndex(index) {
                self.vm.updateLang {
                    self.updateLang()
                }
            }
        }
        
        ddDictOnline.anchorView = dictOnlineCell
        ddDictOnline.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectedDictOnlineIndex else {return}
            self.vm.selectedDictOnlineIndex = index
            self.vm.updateDictOnline {
                self.updateDictOnline()
            }
        }
        
        ddDictNote.anchorView = dictNoteCell
        ddDictNote.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectedDictNoteIndex else {return}
            self.vm.selectedDictNoteIndex = index
            self.vm.updateDictNote {
                self.updateDictNote()
            }
        }
        
        ddTextbook.anchorView = textbookCell
        ddTextbook.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectedTextbookIndex else {return}
            self.vm.selectedTextbookIndex = index
            self.vm.updateTextbook {
                self.updateTextbook()
            }
        }
        
        ddUnitFrom.anchorView = unitFromCell
        ddUnitFrom.selectionAction = { [unowned self] (index: Int, item: String) in
            guard self.vm.USUNITFROM != index + 1 else {return}
            self.vm.USUNITFROM = index + 1
            self.vm.updateUnitFrom {
                self.lblUnitFrom.text = item
                if !self.swUnitPartTo.isOn || self.vm.isInvalidUnitPart {self.updateUnitPartTo()}
            }
        }
        
        ddPartFrom.anchorView = partFromCell
        ddPartFrom.selectionAction = { [unowned self] (index: Int, item: String) in
            guard self.vm.USPARTFROM != index + 1 else {return}
            self.vm.USPARTFROM = index + 1
            self.vm.updatePartFrom {
                self.lblPartFrom.text = item
                if !self.swUnitPartTo.isOn || self.vm.isInvalidUnitPart {self.updateUnitPartTo()}
            }
        }
        
        ddUnitTo.anchorView = unitToCell
        ddUnitTo.selectionAction = { [unowned self] (index: Int, item: String) in
            guard self.vm.USUNITTO != index + 1 else {return}
            self.vm.USUNITTO = index + 1
            self.vm.updateUnitTo {
                self.lblUnitTo.text = item
                if self.vm.isInvalidUnitPart {self.updateUnitPartFrom()}
            }
        }
        
        ddPartTo.anchorView = partToCell
        ddPartTo.selectionAction = { [unowned self] (index: Int, item: String) in
            guard self.vm.USPARTTO != index + 1 else {return}
            self.vm.USPARTTO = index + 1
            self.vm.updatePartTo {
                self.lblPartTo.text = item
                if self.vm.isInvalidUnitPart {self.updateUnitPartFrom()}
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            ddLang.show()
        case 1:
            ddDictOnline.show()
        case 2:
            ddDictNote.show()
        case 3:
            ddTextbook.show()
        default:
            switch indexPath.row {
            case 0:
                ddUnitFrom.show()
            case 1:
                ddPartFrom.show()
            case 3 where swUnitPartTo.isOn:
                ddUnitTo.show()
            case 4 where swUnitPartTo.isOn:
                ddPartTo.show()
            default:
                break
            }
        }
    }
    
    func updateLang() {
        let item = vm.selectedLang
        langCell.textLabel!.text = item.LANGNAME
        updateDictOnline()
        updateDictNote()
        updateTextbook()
    }
    
    func updateDictOnline() {
        let item = vm.selectedDictOnline
        dictOnlineCell.textLabel!.text = item.DICTNAME
        dictOnlineCell.detailTextLabel!.text = item.URL
        ddDictOnline.dataSource = vm.arrDictsOnline.map { $0.DICTNAME! }
        ddDictOnline.selectRow(vm.selectedDictOnlineIndex)
    }
    
    func updateDictNote() {
        if vm.arrDictsNote.isEmpty {
            // if the label text is set to an empty string,
            // it will remain to be empty and can no longer be changed. (why ?)
            dictNoteCell.textLabel!.text = " "
            dictNoteCell.detailTextLabel!.text = " "
            ddDictNote.dataSource = []
        } else {
            let item = vm.selectedDictNote!
            dictNoteCell.textLabel!.text = item.DICTNAME!
            dictNoteCell.detailTextLabel!.text = item.URL!
            dictNoteCell.setNeedsDisplay()
            ddDictNote.dataSource = vm.arrDictsNote.map { $0.DICTNAME! }
            ddDictNote.selectRow(vm.selectedDictNoteIndex)
        }
    }

    func updateTextbook() {
        let item = vm.selectedTextbook
        textbookCell.textLabel!.text = item.TEXTBOOKNAME
        textbookCell.detailTextLabel!.text = "\(item.UNITS) Units"
        lblUnitFrom.text = "\(vm.USUNITFROM)"
        lblUnitTo.text = "\(vm.USUNITTO)"
        lblPartFrom.text = vm.arrParts[vm.USPARTFROM - 1]
        lblPartTo.text = vm.arrParts[vm.USPARTTO - 1]
        swUnitPartTo.isOn = !vm.isSingleUnitPart
        swUnitPartToValueChanged(self)
        ddTextbook.dataSource = vm.arrTextbooks.map { $0.TEXTBOOKNAME }
        ddTextbook.selectRow(vm.selectedTextbookIndex)
        ddUnitFrom.dataSource = vm.arrUnits
        ddUnitFrom.selectRow(vm.USUNITFROM - 1)
        ddPartFrom.dataSource = vm.arrParts
        ddPartFrom.selectRow(vm.USPARTFROM - 1)
        ddUnitTo.dataSource = vm.arrUnits
        ddUnitTo.selectRow(vm.USUNITTO - 1)
        ddPartTo.dataSource = vm.arrParts
        ddPartTo.selectRow(vm.USPARTTO - 1)
    }
    
    func updateUnitPartFrom() {
        if vm.USUNITFROM != vm.USUNITTO {
            vm.USUNITFROM = vm.USUNITTO
            vm.updateUnitFrom {
                self.lblUnitFrom.text = self.lblUnitTo.text
            }
        }
        if vm.USPARTFROM != vm.USPARTTO {
            vm.USPARTFROM = vm.USPARTTO
            vm.updatePartFrom {
                self.lblPartFrom.text = self.lblPartTo.text
            }
        }
    }
    
    func updateUnitPartTo() {
        if vm.USUNITTO != vm.USUNITFROM {
            vm.USUNITTO = vm.USUNITFROM
            vm.updateUnitTo {
                self.lblUnitTo.text = self.lblUnitFrom.text
            }
        }
        if vm.USPARTTO != vm.USPARTFROM {
            vm.USPARTTO = vm.USPARTFROM
            vm.updatePartTo {
                self.lblPartTo.text = self.lblPartFrom.text
            }
        }
    }
    
    @IBAction func swUnitPartToValueChanged(_ sender: AnyObject) {
        let b = swUnitPartTo.isOn
        lblUnitTo.isEnabled = b
        lblPartTo.isEnabled = b
        lblUnitToTitle.isEnabled = b
        lblPartToTitle.isEnabled = b
        if sender !== self && !b {updateUnitPartTo()}
    }
}
