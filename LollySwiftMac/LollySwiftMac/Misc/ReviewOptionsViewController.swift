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
    @IBOutlet weak var scOnRepeat: NSSegmentedControl!
    @IBOutlet weak var scMoveForward: NSSegmentedControl!
    @IBOutlet weak var tfInterval: NSTextField!
    @IBOutlet weak var stpInterval: NSStepper!
    @IBOutlet weak var tfGroupSelected: NSTextField!
    @IBOutlet weak var stpGroupSelected: NSStepper!
    @IBOutlet weak var tfGroupCount: NSTextField!
    @IBOutlet weak var stpGroupCount: NSStepper!
    @IBOutlet weak var scSpeak: NSSegmentedControl!
    @IBOutlet weak var tfReviewCount: NSTextField!
    @IBOutlet weak var stpReviewCount: NSStepper!
    @IBOutlet weak var btnOK: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        vm = ReviewOptionsViewModel(options: options)
        
        _ = vm.optionsEdit.mode <~> pubMode.rx.selectedItemIndex
        _ = vm.optionsEdit.shuffled <~> scOrder.rx.isOn
        _ = vm.optionsEdit.onRepeat <~> scOnRepeat.rx.isOn
        _ = vm.optionsEdit.moveForward <~> scMoveForward.rx.isOn
        _ = vm.optionsEdit.interval <~> stpInterval.rx.integerValue
        _ = vm.optionsEdit.interval.map { String($0) } ~> tfInterval.rx.text.orEmpty
        _ = vm.optionsEdit.groupSelected <~> stpGroupSelected.rx.integerValue
        _ = vm.optionsEdit.groupSelected.map { String($0) } ~> tfGroupSelected.rx.text.orEmpty
        _ = vm.optionsEdit.groupCount <~> stpGroupCount.rx.integerValue
        _ = vm.optionsEdit.groupCount.map { String($0) } ~> tfGroupCount.rx.text.orEmpty
        _ = vm.optionsEdit.speakingEnabled <~> scSpeak.rx.isOn
        _ = vm.optionsEdit.reviewCount <~> stpReviewCount.rx.integerValue
        _ = vm.optionsEdit.reviewCount.map { String($0) } ~> tfReviewCount.rx.text.orEmpty
        btnOK.rx.tap.take(1).subscribe(onCompleted: { [unowned self] in
            self.vm.onOK()
            self.complete?()
            self.dismiss(self.btnOK)
        }) ~ rx.disposeBag
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
