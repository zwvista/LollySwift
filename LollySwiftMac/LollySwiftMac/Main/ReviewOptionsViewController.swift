//
//  ReviewOptionsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/06/26.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa

class ReviewOptionsViewController: NSViewController {

    var options: MReviewOptions!
    var vm: ReviewOptionsViewModel!
    var complete: (() -> Void)?

    @IBOutlet weak var pubMode: NSPopUpButton!
    @IBOutlet weak var scOrder: NSSegmentedControl!
    @IBOutlet weak var tfInterval: NSTextField!
    @IBOutlet weak var stpInterval: NSStepper!
    @IBOutlet weak var tfGroupSelected: NSTextField!
    @IBOutlet weak var stpGroupSelected: NSStepper!
    @IBOutlet weak var tfGroupCount: NSTextField!
    @IBOutlet weak var stpGroupCount: NSStepper!
    @IBOutlet weak var btnOK: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        vm = ReviewOptionsViewModel(options: options)
        
        _ = vm.modeEnabled ~> pubMode.rx.isEnabled
        _ = vm.optionsEdit.mode <~> pubMode.rx.selectedItemIndex
        _ = vm.optionsEdit.shuffled <~> scOrder.rx.isOn
        _ = vm.optionsEdit.interval <~> stpInterval.rx.integerValue
        _ = vm.optionsEdit.interval.map { $0.toString } ~> tfInterval.rx.text.orEmpty
        _ = vm.optionsEdit.groupSelected <~> stpGroupSelected.rx.integerValue
        _ = vm.optionsEdit.groupSelected.map { $0.toString } ~> tfGroupSelected.rx.text.orEmpty
        _ = vm.optionsEdit.groupCount <~> stpGroupCount.rx.integerValue
        _ = vm.optionsEdit.groupCount.map { $0.toString } ~> tfGroupCount.rx.text.orEmpty
        btnOK.rx.tap.subscribe { [unowned self] _ in
            self.vm.onOK()
            self.complete?()
            self.dismiss(self.btnOK)
        } ~ rx.disposeBag
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
