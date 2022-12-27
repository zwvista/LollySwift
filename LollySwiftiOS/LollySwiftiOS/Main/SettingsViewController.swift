//
//  SettingsViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/16.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa

class SettingsViewController: UITableViewController, SettingsViewModelDelegate {

    @IBOutlet weak var lblLang: UILabel!
    @IBOutlet weak var btnLang: UIButton!
    @IBOutlet weak var lblVoice: UILabel!
    @IBOutlet weak var lblVoiceSub: UILabel!
    @IBOutlet weak var btnVoice: UIButton!
    @IBOutlet weak var lblDictReference: UILabel!
    @IBOutlet weak var lblDictReferenceSub: UILabel!
    @IBOutlet weak var btnDictReference: UIButton!
    @IBOutlet weak var lblDictNote: UILabel!
    @IBOutlet weak var lblDictNoteSub: UILabel!
    @IBOutlet weak var btnDictNote: UIButton!
    @IBOutlet weak var lblDictTranslation: UILabel!
    @IBOutlet weak var lblDictTranslationSub: UILabel!
    @IBOutlet weak var btnDictTranslation: UIButton!
    @IBOutlet weak var lblTextbook: UILabel!
    @IBOutlet weak var lblTextbookSub: UILabel!
    @IBOutlet weak var btnTextbook: UIButton!
    @IBOutlet weak var lblUnitFromTitle: UILabel!
    @IBOutlet weak var lblUnitFrom: UILabel!
    @IBOutlet weak var btnUnitFrom: UIButton!
    @IBOutlet weak var lblPartFromTitle: UILabel!
    @IBOutlet weak var lblPartFrom: UILabel!
    @IBOutlet weak var btnPartFrom: UIButton!
    @IBOutlet weak var btnToType: UIButton!
    @IBOutlet weak var lblUnitToTitle: UILabel!
    @IBOutlet weak var lblUnitTo: UILabel!
    @IBOutlet weak var btnUnitTo: UIButton!
    @IBOutlet weak var lblPartToTitle: UILabel!
    @IBOutlet weak var lblPartTo: UILabel!
    @IBOutlet weak var btnPartTo: UIButton!
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var btnNext: UIButton!

    var vm: SettingsViewModel { vmSettings }
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.delegate = self

        vm.$unitToEnabled ~> (lblUnitTo, \.isEnabled) ~ subscriptions
        vm.$unitToEnabled ~> (lblUnitToTitle, \.isEnabled) ~ subscriptions
        vm.$unitToEnabled ~> (btnUnitTo, \.isEnabled) ~ subscriptions
        vm.$partToEnabled ~> (lblPartTo, \.isEnabled) ~ subscriptions
        vm.$partToEnabled ~> (lblPartToTitle, \.isEnabled) ~ subscriptions
        vm.$partToEnabled ~> (btnPartTo, \.isEnabled) ~ subscriptions
        vm.$previousEnabled ~> (btnPrevious, \.isEnabled) ~ subscriptions
        vm.$nextEnabled ~> (btnNext, \.isEnabled) ~ subscriptions
        vm.$previousTitle ~> (btnPrevious, \.titleNormal) ~ subscriptions
        vm.$nextTitle ~> (btnNext, \.titleNormal) ~ subscriptions
        vm.$partFromEnabled ~> (lblPartFrom, \.isEnabled) ~ subscriptions
        vm.$partFromEnabled ~> (lblPartFromTitle, \.isEnabled) ~ subscriptions
        vm.$partFromEnabled ~> (btnPartFrom, \.isEnabled) ~ subscriptions
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

    func onUpdateLang() {
        func configMenuLang() {
            btnLang.menu = UIMenu(title: "", options: .displayInline, children: vm.arrLanguages.map(\.LANGNAME).enumerated().map { index, item in
                UIAction(title: item, state: index == vm.selectedLangIndex ? .on : .off) { [unowned self] _ in
                    guard index != vm.selectedLangIndex else {return}
                    vm.selectedLangIndex = index
                    configMenuLang()
                }
            })
            btnLang.showsMenuAsPrimaryAction = true
        }
        configMenuLang()
        lblLang.text = vm.selectedLang.LANGNAME

        onUpdateiOSVoice()
        onUpdateDictReference()
        onUpdateDictNote()
        onUpdateDictTranslation()
        onUpdateTextbook()
     }

    func onUpdateiOSVoice() {
        func configMenuVoice() {
            btnVoice.menu = UIMenu(title: "", options: .displayInline, children: vm.arriOSVoices.map(\.VOICENAME).enumerated().map { index, item in
                UIAction(title: item, state: index == vm.selectediOSVoiceIndex ? .on : .off) { [unowned self] _ in
                    guard index != vm.selectediOSVoiceIndex else {return}
                    vm.selectediOSVoiceIndex = index
                    configMenuVoice()
                }
            })
            btnVoice.showsMenuAsPrimaryAction = true
        }
        configMenuVoice()
        lblVoice.text = vm.selectediOSVoice.VOICENAME
        lblVoiceSub.text = vm.selectediOSVoice.VOICELANG
    }

    func onUpdateDictReference() {
        func configMenuDictReference() {
            btnVoice.menu = UIMenu(title: "", options: .displayInline, children: vm.arrDictsReference.map(\.DICTNAME).enumerated().map { index, item in
                UIAction(title: item, state: index == vm.selectedDictReferenceIndex ? .on : .off) { [unowned self] _ in
                    guard index != vm.selectedDictReferenceIndex else {return}
                    vm.selectedDictReferenceIndex = index
                    configMenuDictReference()
                }
            })
            btnVoice.showsMenuAsPrimaryAction = true
        }
        configMenuDictReference()
        lblDictReference.text = vm.selectedDictReference.DICTNAME
        lblDictReferenceSub.text = vm.selectedDictReference.URL
    }

    func onUpdateDictNote() {
        func configMenuDictNote() {
            btnDictNote.menu = UIMenu(title: "", options: .displayInline, children: vm.arrDictsNote.isEmpty ? [] : vm.arrDictsNote.map(\.DICTNAME).enumerated().map { index, item in
                UIAction(title: item, state: index == vm.selectedDictNoteIndex ? .on : .off) { [unowned self] _ in
                    guard index != vm.selectedDictNoteIndex else {return}
                    vm.selectedDictNoteIndex = index
                    configMenuDictNote()
                }
            })
            btnDictNote.showsMenuAsPrimaryAction = true
        }
        configMenuDictNote()
        lblDictNote.text = vm.selectedDictNote.DICTNAME
        lblDictNoteSub.text = vm.selectedDictNote.URL
    }

    func onUpdateDictTranslation() {
        func configMenuDictTranslation() {
            btnDictTranslation.menu = UIMenu(title: "", options: .displayInline, children: vm.arrDictsTranslation.isEmpty ? [] : vm.arrDictsTranslation.map(\.DICTNAME).enumerated().map { index, item in
                UIAction(title: item, state: index == vm.selectedDictTranslationIndex ? .on : .off) { [unowned self] _ in
                    guard index != vm.selectedDictTranslationIndex else {return}
                    vm.selectedDictTranslationIndex = index
                    configMenuDictTranslation()
                }
            })
            btnDictTranslation.showsMenuAsPrimaryAction = true
        }
        configMenuDictTranslation()
        lblDictTranslation.text = vm.selectedDictTranslation.DICTNAME
        lblDictTranslationSub.text = vm.selectedDictTranslation.URL
    }

    func onUpdateTextbook() {
        func configMenuTextbook() {
            btnTextbook.menu = UIMenu(title: "", options: .displayInline, children: vm.arrTextbooks.map(\.TEXTBOOKNAME).enumerated().map { index, item in
                UIAction(title: item, state: index == vm.selectedTextbookIndex ? .on : .off) { [unowned self] _ in
                    guard index != vm.selectedTextbookIndex else {return}
                    vm.selectedTextbookIndex = index
                    configMenuTextbook()
                }
            })
            btnTextbook.showsMenuAsPrimaryAction = true
        }
        configMenuTextbook()
        lblTextbook.text = vm.selectedTextbook.TEXTBOOKNAME
        lblTextbookSub.text = "\(vm.unitCount) Units"

        func configMenuToType() {
            btnToType.menu = UIMenu(title: "", options: .displayInline, children: SettingsViewModel.arrToTypes.enumerated().map { index, item in
                UIAction(title: item, state: index == vm.toType_ ? .on : .off) { [unowned self] _ in
                    vm.toType_ = index
                    configMenuToType()
                }
            })
            btnToType.showsMenuAsPrimaryAction = true
        }
        configMenuToType()

        guard !vm.arrUnits.isEmpty else {return}
        onUpdateUnitFrom()
        onUpdatePartFrom()
        onUpdateUnitTo()
        onUpdatePartTo()
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
        func configMenuUnitFrom() {
            btnUnitFrom.menu = UIMenu(title: "", options: .displayInline, children: vm.arrUnits.map(\.label).enumerated().map { index, item in
                UIAction(title: item, state: index == vm.selectedUnitFromIndex ? .on : .off) { [unowned self] _ in
                    guard index != vm.selectedUnitFromIndex else {return}
                    vm.selectedUnitFromIndex = index
                }
            })
            btnUnitFrom.showsMenuAsPrimaryAction = true
        }
        configMenuUnitFrom()
        lblUnitFrom.text = vm.selectedUnitFromText
    }

    func onUpdatePartFrom() {
        func configMenuPartFrom() {
            btnPartFrom.menu = UIMenu(title: "", options: .displayInline, children: vm.arrParts.map(\.label).enumerated().map { index, item in
                UIAction(title: item, state: index == vm.selectedPartFromIndex ? .on : .off) { [unowned self] _ in
                    guard index != vm.selectedPartFromIndex else {return}
                    vm.selectedPartFromIndex = index
                }
            })
            btnPartFrom.showsMenuAsPrimaryAction = true
        }
        configMenuPartFrom()
        lblPartFrom.text = vm.selectedPartFromText
    }

    func onUpdateUnitTo() {
        func configMenuToType() {
            btnUnitTo.menu = UIMenu(title: "", options: .displayInline, children: vm.arrUnits.map(\.label).enumerated().map { index, item in
                UIAction(title: item, state: index == vm.selectedUnitToIndex ? .on : .off) { [unowned self] _ in
                    guard index != vm.selectedUnitToIndex else {return}
                    vm.selectedUnitToIndex = index
                }
            })
            btnUnitTo.showsMenuAsPrimaryAction = true
        }
        configMenuToType()
        lblUnitTo.text = vm.selectedUnitToText
    }

    func onUpdatePartTo() {
        func configMenuToType() {
            btnPartTo.menu = UIMenu(title: "", options: .displayInline, children: vm.arrParts.map(\.label).enumerated().map { index, item in
                UIAction(title: item, state: index == vm.selectedPartToIndex ? .on : .off) { [unowned self] _ in
                    guard index != vm.selectedPartToIndex else {return}
                    vm.selectedPartToIndex = index
                }
            })
            btnPartTo.showsMenuAsPrimaryAction = true
        }
        configMenuToType()
        lblPartTo.text = vm.selectedPartToText
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }

}
