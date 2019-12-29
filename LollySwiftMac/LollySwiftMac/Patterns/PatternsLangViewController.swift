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
    @IBOutlet weak var scTextFilter: NSSegmentedControl!
    @IBOutlet weak var tfFilter: NSTextField!
    @IBOutlet weak var tfURL: NSTextField!
    @IBOutlet weak var tvPatterns: NSTableView!
    @IBOutlet weak var tfStatusText: NSTextField!

    var vm: PatternsLangViewModel!
    let disposeBag = DisposeBag()
    var vmSettings: SettingsViewModel! {
        return vm.vmSettings
    }
    var arrPatterns: [MLangPattern] {
        return vm.arrPatternsFiltered ?? vm.arrPatterns
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
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
    
    func updateStatusText() {
        tfStatusText.stringValue = "\(tvPatterns.numberOfRows) Patterns"
    }

}
