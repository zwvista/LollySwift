//
//  ReviewOptionsViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2019/06/28.
//  Copyright © 2019 趙 偉. All rights reserved.
//

import UIKit
import RxSwift
import NSObject_Rx
import RxBinding

class ReviewOptionsViewController: UITableViewController {

    @IBOutlet weak var reviewModeCell: UITableViewCell!
    @IBOutlet weak var lblReviewMode: UILabel!
    @IBOutlet weak var btnReviewMode: UIButton!
    @IBOutlet weak var swOrder: UISwitch!
    @IBOutlet weak var swSpeak: UISwitch!
    @IBOutlet weak var swOnRepeat: UISwitch!
    @IBOutlet weak var swMoveForward: UISwitch!
    @IBOutlet weak var tfInterval: UITextField!
    @IBOutlet weak var tfGroupSelected: UITextField!
    @IBOutlet weak var tfGroupCount: UITextField!
    @IBOutlet weak var tfReviewCount: UITextField!

    var vm: ReviewOptionsViewModel!
    var complete: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        func configMenu() {
            btnReviewMode.menu = UIMenu(title: "", options: .displayInline, children: SettingsViewModel.reviewModes.enumerated().map { index, item in
                UIAction(title: item, state: index == vm.optionsEdit.mode ? .on : .off) { [unowned self] _ in
                    vm.optionsEdit.mode = index
                    vm.optionsEdit.modeString = item
                    configMenu()
                }
            })
            btnReviewMode.showsMenuAsPrimaryAction = true
        }
        configMenu()

        _ = vm.optionsEdit.modeString_ ~> lblReviewMode.rx.text
        _ = vm.optionsEdit.shuffled <~> swOrder.rx.isOn
        _ = vm.optionsEdit.speakingEnabled <~> swSpeak.rx.isOn
        _ = vm.optionsEdit.onRepeat <~> swOnRepeat.rx.isOn
        _ = vm.optionsEdit.moveForward <~> swMoveForward.rx.isOn
        _ = vm.optionsEdit.interval.map { String($0) } ~> tfInterval.rx.text.orEmpty
        _ = vm.optionsEdit.groupSelected.map { String($0) } ~> tfGroupSelected.rx.text.orEmpty
        _ = vm.optionsEdit.groupCount.map { String($0) } ~> tfGroupCount.rx.text.orEmpty
        _ = vm.optionsEdit.reviewCount.map { String($0) } ~> tfReviewCount.rx.text.orEmpty
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
