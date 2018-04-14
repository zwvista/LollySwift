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
    @IBOutlet weak var dictCell: UITableViewCell!
    @IBOutlet weak var noteSiteCell: UITableViewCell!
    @IBOutlet weak var textbookCell: UITableViewCell!
    @IBOutlet weak var unitFromCell: UITableViewCell!
    @IBOutlet weak var partFromCell: UITableViewCell!
    @IBOutlet weak var unitToCell: UITableViewCell!
    @IBOutlet weak var partToCell: UITableViewCell!
    @IBOutlet weak var lblUnitFrom: UILabel!
    @IBOutlet weak var lblUnitTo: UILabel!
    @IBOutlet weak var swUnitTo: UISwitch!
    @IBOutlet weak var lblPartFrom: UILabel!
    @IBOutlet weak var lblPartTo: UILabel!
    @IBOutlet weak var lblUnitToTitle: UILabel!
    @IBOutlet weak var lblPartToTitle: UILabel!
    
    let ddLang = DropDown()
    let ddDict = DropDown()
    let ddNoteSite = DropDown()
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
        
        ddDict.anchorView = dictCell
        ddDict.dataSource = vm.arrDictionaries.map { $0.DICTNAME! }
        ddDict.selectRow(vm.selectedDictIndex)
        ddDict.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectedDictIndex else {return}
            self.vm.selectedDictIndex = index
            self.vm.updateDict {
                self.updateDict()
            }
        }
        
        ddNoteSite.anchorView = noteSiteCell
        ddNoteSite.dataSource = vm.arrNoteSites.map { $0.DICTNAME! }
        ddNoteSite.selectRow(vm.selectedNoteSiteIndex)
        ddNoteSite.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectedNoteSiteIndex else {return}
            self.vm.selectedNoteSiteIndex = index
            self.vm.updateNoteSite {
                self.updateNoteSite()
            }
        }
        
        ddTextbook.anchorView = textbookCell
        ddTextbook.dataSource = vm.arrTextbooks.map { $0.TEXTBOOKNAME }
        ddTextbook.selectRow(vm.selectedTextbookIndex)
        ddTextbook.selectionAction = { [unowned self] (index: Int, item: String) in
            guard index != self.vm.selectedTextbookIndex else {return}
            self.vm.selectedTextbookIndex = index
            self.vm.updateTextbook {
                self.updateTextbook()
            }
        }
        
        ddUnitFrom.anchorView = unitFromCell
        ddUnitFrom.dataSource = vm.arrUnits
        ddUnitFrom.selectRow(vm.USUNITFROM - 1)
        ddUnitFrom.selectionAction = { [unowned self] (index: Int, item: String) in
            guard self.vm.USUNITFROM != index + 1 else {return}
            self.vm.USUNITFROM = index + 1
            self.vm.updateUnitFrom {
                self.lblUnitFrom.text = item
                if !self.swUnitTo.isOn || self.vm.isInvalidUnitPart {self.updateUnitPartTo()}
            }
        }
        
        ddPartFrom.anchorView = partFromCell
        ddPartFrom.dataSource = vm.arrParts
        ddPartFrom.selectRow(vm.USPARTFROM - 1)
        ddPartFrom.selectionAction = { [unowned self] (index: Int, item: String) in
            guard self.vm.USPARTFROM != index + 1 else {return}
            self.vm.USPARTFROM = index + 1
            self.vm.updatePartFrom {
                self.lblPartFrom.text = item
                if !self.swUnitTo.isOn || self.vm.isInvalidUnitPart {self.updateUnitPartTo()}
            }
        }
        
        ddUnitTo.anchorView = unitToCell
        ddUnitTo.dataSource = vm.arrUnits
        ddUnitTo.selectRow(vm.USUNITTO - 1)
        ddUnitTo.selectionAction = { [unowned self] (index: Int, item: String) in
            guard self.vm.USUNITTO != index + 1 else {return}
            self.vm.USUNITTO = index + 1
            self.vm.updateUnitTo {
                self.lblUnitTo.text = item
                if self.vm.isInvalidUnitPart {self.updateUnitPartFrom()}
            }
        }
        
        ddPartTo.anchorView = partToCell
        ddPartTo.dataSource = vm.arrParts
        ddPartTo.selectRow(vm.USPARTTO - 1)
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
            ddDict.show()
        case 2:
            ddNoteSite.show()
        case 3:
            ddTextbook.show()
        default:
            switch indexPath.row {
            case 0:
                ddUnitFrom.show()
            case 1:
                ddPartFrom.show()
            case 3 where swUnitTo.isOn:
                ddUnitTo.show()
            case 4 where swUnitTo.isOn:
                ddPartTo.show()
            default:
                break
            }
        }
    }
    
    func updateLang() {
        let m = vm.selectedLang
        langCell.textLabel!.text = m.LANGNAME
        updateDict()
        updateNoteSite()
        updateTextbook()
    }
    
    func updateDict() {
        let m = vm.selectedDict
        dictCell.textLabel!.text = m.DICTNAME
        dictCell.detailTextLabel!.text = m.URL
    }
    
    func updateNoteSite() {
        if vm.arrNoteSites.isEmpty {
            // if the label text is set to an empty string,
            // it will remain to be empty and can no longer be changed. (why ?)
            noteSiteCell.textLabel!.text = " "
            noteSiteCell.detailTextLabel!.text = " "
        } else {
            let m = vm.selectedNoteSite!
            noteSiteCell.textLabel!.text = m.DICTNAME!
            noteSiteCell.detailTextLabel!.text = m.URL!
            noteSiteCell.setNeedsDisplay()
        }
    }

    func updateTextbook() {
        let m = vm.selectedTextbook
        textbookCell.textLabel!.text = m.TEXTBOOKNAME
        textbookCell.detailTextLabel!.text = "\(m.UNITS) Units"
        lblUnitFrom.text = "\(vm.USUNITFROM)"
        lblUnitTo.text = "\(vm.USUNITTO)"
        lblPartFrom.text = vm.arrParts[vm.USPARTFROM - 1]
        lblPartTo.text = vm.arrParts[vm.USPARTTO - 1]
        swUnitTo.isOn = !vm.isSingleUnitPart
        swUnitToValueChanged(self)
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
    
    @IBAction func swUnitToValueChanged(_ sender: AnyObject) {
        let b = swUnitTo.isOn
        lblUnitTo.isEnabled = b
        lblPartTo.isEnabled = b
        lblUnitToTitle.isEnabled = b
        lblPartToTitle.isEnabled = b
        if sender !== self && !b {updateUnitPartTo()}
    }
}
