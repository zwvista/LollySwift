//
//  ReviewOptionsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/06/26.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa
import Combine

class ReviewOptionsViewController: NSViewController {

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

    var options: MReviewOptions!
    var vm: ReviewOptionsViewModel!
    var complete: (() -> Void)?
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        vm = ReviewOptionsViewModel(options: options)
        
        vm.optionsEdit.$mode <~> pubMode.selectedItemIndexProperty ~ subscriptions
        vm.optionsEdit.$shuffled <~> scOrder.isOnProperty ~ subscriptions
        vm.optionsEdit.$onRepeat <~> scOnRepeat.isOnProperty ~ subscriptions
        vm.optionsEdit.$moveForward <~> scMoveForward.isOnProperty ~ subscriptions
        vm.optionsEdit.$interval <~> stpInterval.rx.integerValue
        vm.optionsEdit.$interval.map { String($0) } ~> (tfInterval.rx.text.orEmpty
        vm.optionsEdit.$groupSelected <~> stpGroupSelected.rx.integerValue
        vm.optionsEdit.$groupSelected.map { String($0) } ~> (tfGroupSelected.rx.text.orEmpty
        vm.optionsEdit.$groupCount <~> stpGroupCount.rx.integerValue
        vm.optionsEdit.$groupCount.map { String($0) } ~> (tfGroupCount.rx.text.orEmpty
        vm.optionsEdit.$speakingEnabled <~> scSpeak.isOnProperty ~ subscriptions
        vm.optionsEdit.$reviewCount <~> stpReviewCount.rx.integerValue
        vm.optionsEdit.$reviewCount.map { String($0) } ~> (tfReviewCount, \.stringValue)
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
