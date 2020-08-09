//
//  ReviewOptionsViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2019/06/28.
//  Copyright © 2019 趙 偉. All rights reserved.
//

import UIKit

class ReviewOptionsViewController: UITableViewController {
    
    var options: MReviewOptions!
    var vm: ReviewOptionsViewModel!
    var complete: (() -> Void)?
    
    @IBOutlet weak var tfMode: UILabel!
    @IBOutlet weak var scOrder: UISwitch!
    @IBOutlet weak var scLevel: UISwitch!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var tfInterval: UITextField!
    @IBOutlet weak var tfGroupSelected: UITextField!
    @IBOutlet weak var tfGroupCount: UITextField!
    @IBOutlet weak var btnDone: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        vm = ReviewOptionsViewModel(options: options)
        
//        _ = vm.optionsEdit.mode <~> pubMode.rx.selectedItemIndex
        _ = vm.optionsEdit.shuffled <~> scOrder.rx.isOn
        _ = vm.optionsEdit.levelHidden ~> lblLevel.rx.isHidden
        _ = vm.optionsEdit.levelHidden ~> scLevel.rx.isHidden
        _ = vm.optionsEdit.levelge0only <~> scLevel.rx.isOn
//        _ = vm.optionsEdit.interval <~> stpInterval.rx.integerValue
        _ = vm.optionsEdit.interval.map { $0.toString } ~> tfInterval.rx.text.orEmpty
//        _ = vm.optionsEdit.groupSelected <~> stpGroupSelected.rx.integerValue
        _ = vm.optionsEdit.groupSelected.map { $0.toString } ~> tfGroupSelected.rx.text.orEmpty
//        _ = vm.optionsEdit.groupCount <~> stpGroupCount.rx.integerValue
        _ = vm.optionsEdit.groupCount.map { $0.toString } ~> tfGroupCount.rx.text.orEmpty
    }
    
    func onDone() {
    }
}
