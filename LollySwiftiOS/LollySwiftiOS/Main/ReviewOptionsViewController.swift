//
//  ReviewOptionsViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2019/06/28.
//  Copyright © 2019 趙 偉. All rights reserved.
//

import UIKit
import Combine

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
    var subscriptions = Set<AnyCancellable>()

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

        vm.optionsEdit.$modeString ~> (lblReviewMode, \.text!) ~ subscriptions
        vm.optionsEdit.$shuffled <~> swOrder.isOnProperty ~ subscriptions
        vm.optionsEdit.$speakingEnabled <~> swSpeak.isOnProperty ~ subscriptions
        vm.optionsEdit.$onRepeat <~> swOnRepeat.isOnProperty ~ subscriptions
        vm.optionsEdit.$moveForward <~> swMoveForward.isOnProperty ~ subscriptions
        vm.optionsEdit.$interval.map { String($0) }.eraseToAnyPublisher() ~> (tfInterval, \.text2) ~ subscriptions
        vm.optionsEdit.$groupSelected.map { String($0) }.eraseToAnyPublisher() ~> (tfGroupSelected, \.text2) ~ subscriptions
        vm.optionsEdit.$groupCount.map { String($0) }.eraseToAnyPublisher() ~> (tfGroupCount, \.text2) ~ subscriptions
        vm.optionsEdit.$reviewCount.map { String($0) }.eraseToAnyPublisher() ~> (tfReviewCount, \.text2) ~ subscriptions
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
