//
//  SettingsViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/16.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import RxSwift
import NSObject_Rx
import RxBinding

class SettingsViewController: UITableViewController {

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

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.selectedLangIndex_.filter { $0 != -1 }.subscribe { [unowned self] _ in
            btnLang.menu = UIMenu(title: "", options: .displayInline, children: vm.arrLanguages.map(\.LANGNAME).enumerated().map { index, item in
                UIAction(title: item, state: index == vm.selectedLangIndex ? .on : .off) { [unowned self] _ in
                    guard index != vm.selectedLangIndex else {return}
                    vm.selectedLangIndex = index
                }
            })
            btnLang.showsMenuAsPrimaryAction = true
            lblLang.text = vm.selectedLang.LANGNAME
        } ~ rx.disposeBag

        vm.selectediOSVoiceIndex_.filter { $0 != -1 }.subscribe { [unowned self] _ in
            btnVoice.menu = UIMenu(title: "", options: .displayInline, children: vm.arriOSVoices.map(\.VOICENAME).enumerated().map { index, item in
                UIAction(title: item, state: index == vm.selectediOSVoiceIndex ? .on : .off) { [unowned self] _ in
                    guard index != vm.selectediOSVoiceIndex else {return}
                    vm.selectediOSVoiceIndex = index
                }
            })
            btnVoice.showsMenuAsPrimaryAction = true
            lblVoice.text = vm.selectediOSVoice.VOICENAME
            lblVoiceSub.text = vm.selectediOSVoice.VOICELANG
        } ~ rx.disposeBag

        vm.selectedDictReferenceIndex_.filter { $0 != -1 }.subscribe { [unowned self] _ in
            btnDictReference.menu = UIMenu(title: "", options: .displayInline, children: vm.arrDictsReference.map(\.DICTNAME).enumerated().map { index, item in
                UIAction(title: item, state: index == vm.selectedDictReferenceIndex ? .on : .off) { [unowned self] _ in
                    guard index != vm.selectedDictReferenceIndex else {return}
                    vm.selectedDictReferenceIndex = index
                }
            })
            btnDictReference.showsMenuAsPrimaryAction = true
            lblDictReference.text = vm.selectedDictReference.DICTNAME
            lblDictReferenceSub.text = vm.selectedDictReference.URL
        } ~ rx.disposeBag

        vm.selectedDictNoteIndex_.filter { $0 != -1 }.subscribe { [unowned self] _ in
            btnDictNote.menu = UIMenu(title: "", options: .displayInline, children: vm.arrDictsNote.isEmpty ? [] : vm.arrDictsNote.map(\.DICTNAME).enumerated().map { index, item in
                UIAction(title: item, state: index == vm.selectedDictNoteIndex ? .on : .off) { [unowned self] _ in
                    guard index != vm.selectedDictNoteIndex else {return}
                    vm.selectedDictNoteIndex = index
                }
            })
            btnDictNote.showsMenuAsPrimaryAction = true
            lblDictNote.text = vm.selectedDictNote.DICTNAME
            lblDictNoteSub.text = vm.selectedDictNote.URL
        } ~ rx.disposeBag

        vm.selectedDictTranslationIndex_.filter { $0 != -1 }.subscribe { [unowned self] _ in
            btnDictTranslation.menu = UIMenu(title: "", options: .displayInline, children: vm.arrDictsTranslation.isEmpty ? [] : vm.arrDictsTranslation.map(\.DICTNAME).enumerated().map { index, item in
                UIAction(title: item, state: index == vm.selectedDictTranslationIndex ? .on : .off) { [unowned self] _ in
                    guard index != vm.selectedDictTranslationIndex else {return}
                    vm.selectedDictTranslationIndex = index
                }
            })
            btnDictTranslation.showsMenuAsPrimaryAction = true
            lblDictTranslation.text = vm.selectedDictTranslation.DICTNAME
            lblDictTranslationSub.text = vm.selectedDictTranslation.URL
        } ~ rx.disposeBag

        vm.selectedTextbookIndex_.filter { $0 != -1 }.subscribe { [unowned self] _ in
            btnTextbook.menu = UIMenu(title: "", options: .displayInline, children: vm.arrTextbooks.map(\.TEXTBOOKNAME).enumerated().map { index, item in
                UIAction(title: item, state: index == vm.selectedTextbookIndex ? .on : .off) { [unowned self] _ in
                    guard index != vm.selectedTextbookIndex else {return}
                    vm.selectedTextbookIndex = index
                }
            })
            btnTextbook.showsMenuAsPrimaryAction = true
            lblTextbook.text = vm.selectedTextbook.TEXTBOOKNAME
            lblTextbookSub.text = "\(vm.unitCount) Units"
        } ~ rx.disposeBag

        vm.toType_.subscribe { [unowned self] _ in
            btnToType.menu = UIMenu(title: "", options: .displayInline, children: SettingsViewModel.arrToTypes.enumerated().map { index, item in
                UIAction(title: item, state: index == vm.toType_.value ? .on : .off) { [unowned self] _ in
                    vm.toType_.accept(index)
                }
            })
            btnToType.showsMenuAsPrimaryAction = true
        } ~ rx.disposeBag

        vm.selectedUnitFromIndex_.filter { $0 != -1 }.subscribe { [unowned self] _ in
            btnUnitFrom.menu = UIMenu(title: "", options: .displayInline, children: vm.arrUnits.map(\.label).enumerated().map { index, item in
                UIAction(title: item, state: index == vm.selectedUnitFromIndex ? .on : .off) { [unowned self] _ in
                    guard index != vm.selectedUnitFromIndex else {return}
                    vm.selectedUnitFromIndex = index
                }
            })
            btnUnitFrom.showsMenuAsPrimaryAction = true
            lblUnitFrom.text = vm.selectedUnitFromText
        } ~ rx.disposeBag

        vm.selectedPartFromIndex_.filter { $0 != -1 }.subscribe { [unowned self] _ in
            btnPartFrom.menu = UIMenu(title: "", options: .displayInline, children: vm.arrParts.map(\.label).enumerated().map { index, item in
                UIAction(title: item, state: index == vm.selectedPartFromIndex ? .on : .off) { [unowned self] _ in
                    guard index != vm.selectedPartFromIndex else {return}
                    vm.selectedPartFromIndex = index
                }
            })
            btnPartFrom.showsMenuAsPrimaryAction = true
            lblPartFrom.text = vm.selectedPartFromText
        } ~ rx.disposeBag

        vm.selectedUnitToIndex_.filter { $0 != -1 }.subscribe { [unowned self] _ in
            btnUnitTo.menu = UIMenu(title: "", options: .displayInline, children: vm.arrUnits.map(\.label).enumerated().map { index, item in
                UIAction(title: item, state: index == vm.selectedUnitToIndex ? .on : .off) { [unowned self] _ in
                    guard index != vm.selectedUnitToIndex else {return}
                    vm.selectedUnitToIndex = index
                }
            })
            btnUnitTo.showsMenuAsPrimaryAction = true
            lblUnitTo.text = vm.selectedUnitToText
        } ~ rx.disposeBag

        vm.selectedPartToIndex_.filter { $0 != -1 }.subscribe { [unowned self] _ in
            btnPartTo.menu = UIMenu(title: "", options: .displayInline, children: vm.arrParts.map(\.label).enumerated().map { index, item in
                UIAction(title: item, state: index == vm.selectedPartToIndex ? .on : .off) { [unowned self] _ in
                    guard index != vm.selectedPartToIndex else {return}
                    vm.selectedPartToIndex = index
                }
            })
            btnPartTo.showsMenuAsPrimaryAction = true
            lblPartTo.text = vm.selectedPartToText
        } ~ rx.disposeBag

        _ = vm.unitToEnabled ~> lblUnitTo.rx.isEnabled
        _ = vm.unitToEnabled ~> lblUnitToTitle.rx.isEnabled
        _ = vm.unitToEnabled ~> btnUnitTo.rx.isEnabled
        _ = vm.partToEnabled ~> lblPartTo.rx.isEnabled
        _ = vm.partToEnabled ~> lblPartToTitle.rx.isEnabled
        _ = vm.partToEnabled ~> btnPartTo.rx.isEnabled
        _ = vm.previousEnabled ~> btnPrevious.rx.isEnabled
        _ = vm.nextEnabled ~> btnNext.rx.isEnabled
        _ = vm.previousTitle ~> btnPrevious.rx.title(for: .normal)
        _ = vm.nextTitle ~> btnNext.rx.title(for: .normal)
        _ = vm.partFromEnabled ~> lblPartFrom.rx.isEnabled
        _ = vm.partFromEnabled ~> lblPartFromTitle.rx.isEnabled
        _ = vm.partFromEnabled ~> btnPartFrom.rx.isEnabled
        _ = vm.toTypeTitle ~> btnToType.rx.title(for: .normal)

        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        refresh(refreshControl!)
    }

    @objc func refresh(_ sender: UIRefreshControl) {
        vm.getData().subscribe { _ in
            sender.endRefreshing()
        } ~ rx.disposeBag
    }

    @IBAction func previousUnitPart(_ sender: AnyObject) {
        vm.previousUnitPart().subscribe() ~ rx.disposeBag
    }

    @IBAction func nextUnitPart(_ sender: AnyObject) {
        vm.nextUnitPart().subscribe() ~ rx.disposeBag
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }

}
