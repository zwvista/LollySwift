//
//  ReviewOptionsViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2019/06/28.
//  Copyright © 2019 趙 偉. All rights reserved.
//

import UIKit
import DropDown
import RxSwift
import NSObject_Rx

class ReviewOptionsViewController: UITableViewController {
    
    var options: MReviewOptions!
    var vm: ReviewOptionsViewModel!
    var complete: (() -> Void)?
    
    @IBOutlet weak var reviewModeCell: UITableViewCell!
    @IBOutlet weak var lblReviewMode: UILabel!
    @IBOutlet weak var swOrder: UISwitch!
    @IBOutlet weak var swSpeak: UISwitch!
    @IBOutlet weak var tfInterval: UITextField!
    @IBOutlet weak var tfGroupSelected: UITextField!
    @IBOutlet weak var tfGroupCount: UITextField!
    @IBOutlet weak var tfReviewCount: UITextField!
    let ddReviewMode = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        vm = ReviewOptionsViewModel(options: options)
        
        ddReviewMode.anchorView = reviewModeCell
        ddReviewMode.dataSource = SettingsViewModel.reviewModes
        ddReviewMode.selectionAction = { [unowned self] (index: Int, item: String) in
            self.vm.optionsEdit.mode.accept(index)
            self.vm.optionsEdit.modeString.accept(item)
        }

        _ = vm.optionsEdit.modeString ~> lblReviewMode.rx.text
        _ = vm.optionsEdit.shuffled <~> swOrder.rx.isOn
        _ = vm.optionsEdit.speakingEnabled <~> swSpeak.rx.isOn
//        _ = vm.optionsEdit.interval <~> stpInterval.rx.integerValue
        _ = vm.optionsEdit.interval.map { String($0) } ~> tfInterval.rx.text.orEmpty
//        _ = vm.optionsEdit.groupSelected <~> stpGroupSelected.rx.integerValue
        _ = vm.optionsEdit.groupSelected.map { String($0) } ~> tfGroupSelected.rx.text.orEmpty
//        _ = vm.optionsEdit.groupCount <~> stpGroupCount.rx.integerValue
        _ = vm.optionsEdit.groupCount.map { String($0) } ~> tfGroupCount.rx.text.orEmpty
        _ = vm.optionsEdit.reviewCount.map { String($0) } ~> tfReviewCount.rx.text.orEmpty
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            ddReviewMode.show()
        }
    }
    
    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
