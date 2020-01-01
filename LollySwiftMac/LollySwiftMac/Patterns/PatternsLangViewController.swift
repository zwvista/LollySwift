//
//  PatternsLangViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/12/28.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa
import WebKit
import RxSwift

class PatternsLangViewController: NSViewController, LollyProtocol, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {

    @IBOutlet weak var wvDict: WKWebView!
    @IBOutlet weak var tfNewPattern: NSTextField!
    @IBOutlet weak var scTextFilter: NSSegmentedControl!
    @IBOutlet weak var tfFilter: NSTextField!
    @IBOutlet weak var tfURL: NSTextField!
    @IBOutlet weak var tvPatterns: NSTableView!
    @IBOutlet weak var tfStatusText: NSTextField!
    @IBOutlet weak var tvPhrases: NSTableView!

    var vm: PatternsLangViewModel!
    let disposeBag = DisposeBag()
    @objc var newPattern = ""
    @objc var textFilter = ""
    var vmSettings: SettingsViewModel! {
        return vm.vmSettings
    }
    var arrPatterns: [MLangPattern] {
        return vm.arrPatternsFiltered ?? vm.arrPatterns
    }
    var arrPhrases: [MLangPhrase] {
        return vm.arrPhrases
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
        wvDict.allowsMagnification = true
        wvDict.allowsBackForwardNavigationGestures = true
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tableView === tvPatterns ? arrPatterns.count : arrPhrases.count
    }
    
    @IBAction func endEditing(_ sender: NSTextField) {
        let row = tvPatterns.row(for: sender)
        guard row != -1 else {return}
        let col = tvPatterns.column(for: sender)
        let key = tvPatterns.tableColumns[col].identifier.rawValue
        let item = arrPatterns[row]
        let oldValue = String(describing: item.value(forKey: key))
        var newValue = sender.stringValue
        if key == "PATTERN" {
            newValue = vmSettings.autoCorrectInput(text: newValue)
        }
        guard oldValue != newValue else {return}
        item.setValue(newValue, forKey: key)
        PatternsLangViewModel.update(item: item).subscribe {
            self.tvPatterns.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<self.tvPatterns.tableColumns.count))
        }.disposed(by: disposeBag)
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let columnName = tableColumn!.identifier.rawValue
        if tableView === tvPatterns {
            let item = arrPatterns[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        } else {
            let item = arrPhrases[row]
            cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        }
        return cell
    }

    func settingsChanged() {
        vm = PatternsLangViewModel(settings: AppDelegate.theSettingsViewModel, disposeBag: disposeBag, needCopy: true) {
            self.doRefresh()
        }
    }
    func doRefresh() {
        tvPatterns.reloadData()
        updateStatusText()
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        let textfield = obj.object as! NSControl
        let dict = (obj as NSNotification).userInfo!
        let reason = dict["NSTextMovement"] as! NSNumber
        let code = Int(reason.int32Value)
        guard code == NSReturnTextMovement else {return}
        if textfield === tfNewPattern {
            guard  !newPattern.isEmpty else {return}
            let item = vm.newLangPattern()
            item.PATTERN = vm.vmSettings.autoCorrectInput(text: newPattern)
            PatternsLangViewModel.create(item: item).subscribe(onNext: {
                item.ID = $0
                self.vm.arrPatterns.append(item)
                self.tvPatterns.reloadData()
                self.tfNewPattern.stringValue = ""
                self.newPattern = ""
            }).disposed(by: disposeBag)
        } else if textfield === tfFilter {
            if !textFilter.isEmpty {
                scTextFilter.selectedSegment = 1
                textFilter = vmSettings.autoCorrectInput(text: textFilter)
                tfFilter.stringValue = textFilter
            }
            scTextFilter.performClick(self)
        }
    }

    @IBAction func refreshTableView(_ sender: AnyObject) {
        vm.reload().subscribe {
            self.doRefresh()
        }.disposed(by: disposeBag)
    }
    
    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addPattern(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PatternsLangDetailViewController") as! PatternsLangDetailViewController
        detailVC.vm = vm
        detailVC.item = vm.newLangPattern()
        detailVC.complete = { self.tvPatterns.reloadData(); self.addPattern(self) }
        self.presentAsSheet(detailVC)
    }

    @IBAction func editPattern(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PatternsLangDetailViewController") as! PatternsLangDetailViewController
        detailVC.vm = vm
        let i = tvPatterns.selectedRow
        detailVC.item = MLangPattern()
        detailVC.item.copy(from: arrPatterns[i])
        detailVC.complete = {
            self.arrPatterns[i].copy(from: detailVC.item)
            self.tvPatterns.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tvPatterns.tableColumns.count))
        }
        self.presentAsModalWindow(detailVC)
    }

    func updateStatusText() {
        tfStatusText.stringValue = "\(tvPatterns.numberOfRows) Patterns"
    }
    
    @IBAction func selectPhrases(_ sender: AnyObject) {
//        guard selectedPatternID != 0 else {return}
//        let detailVC = NSStoryboard(name: "Phrases", bundle: nil).instantiateController(withIdentifier: "PhrasesSelectViewController") as! PhrasesSelectViewController
//        detailVC.textFilter = selectedPattern
//        detailVC.wordid = selectedPatternID
//        detailVC.complete = {
//            self.searchPhrases()
//        }
//        self.presentAsModalWindow(detailVC)
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}

class PatternsLangWindowController: NSWindowController, LollyProtocol, NSWindowDelegate, NSTextFieldDelegate {
    
    @IBOutlet weak var toolbar: NSToolbar!
    @IBOutlet weak var scSpeak: NSSegmentedControl!
    // Outlet collections have been implemented for iOS, but not in Cocoa
    // https://stackoverflow.com/questions/24805180/swift-put-multiple-iboutlets-in-an-array
    // @IBOutlet var tbiDicts: [NSToolbarItem]!
    @IBOutlet weak var tbiDict0: NSToolbarItem!
    @IBOutlet weak var tbiDict1: NSToolbarItem!
    @IBOutlet weak var tbiDict2: NSToolbarItem!
    @IBOutlet weak var tbiDict3: NSToolbarItem!
    @IBOutlet weak var tbiDict4: NSToolbarItem!
    @IBOutlet weak var tbiDict5: NSToolbarItem!
    @IBOutlet weak var tbiDict6: NSToolbarItem!
    @IBOutlet weak var tbiDict7: NSToolbarItem!
    @IBOutlet weak var tbiDict8: NSToolbarItem!
    @IBOutlet weak var tbiDict9: NSToolbarItem!
    @IBOutlet weak var tbiDict10: NSToolbarItem!
    @IBOutlet weak var tbiDict11: NSToolbarItem!
    @IBOutlet weak var tbiDict12: NSToolbarItem!
    @IBOutlet weak var tbiDict13: NSToolbarItem!
    @IBOutlet weak var tbiDict14: NSToolbarItem!
    @IBOutlet weak var tbiDict15: NSToolbarItem!
    @IBOutlet weak var tbiDict16: NSToolbarItem!
    @IBOutlet weak var tbiDict17: NSToolbarItem!
    @IBOutlet weak var tbiDict18: NSToolbarItem!
    @IBOutlet weak var tbiDict19: NSToolbarItem!
    @IBOutlet weak var tbiDict20: NSToolbarItem!
    @IBOutlet weak var tbiDict21: NSToolbarItem!
    @IBOutlet weak var tbiDict22: NSToolbarItem!
    @IBOutlet weak var tbiDict23: NSToolbarItem!
    @IBOutlet weak var tbiDict24: NSToolbarItem!
    @IBOutlet weak var tbiDict25: NSToolbarItem!
    @IBOutlet weak var tbiDict26: NSToolbarItem!
    @IBOutlet weak var tbiDict27: NSToolbarItem!
    @IBOutlet weak var tbiDict28: NSToolbarItem!
    @IBOutlet weak var tbiDict29: NSToolbarItem!
    @IBOutlet weak var tbiDict30: NSToolbarItem!
    @IBOutlet weak var tbiDict31: NSToolbarItem!
    @IBOutlet weak var tbiDict32: NSToolbarItem!
    @IBOutlet weak var tbiDict33: NSToolbarItem!
    @IBOutlet weak var tbiDict34: NSToolbarItem!
    @IBOutlet weak var tbiDict35: NSToolbarItem!
    @IBOutlet weak var tbiDict36: NSToolbarItem!
    @IBOutlet weak var tbiDict37: NSToolbarItem!
    @IBOutlet weak var tbiDict38: NSToolbarItem!
    @IBOutlet weak var tbiDict39: NSToolbarItem!
    func settingsChanged() {
    }
    
    
    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
