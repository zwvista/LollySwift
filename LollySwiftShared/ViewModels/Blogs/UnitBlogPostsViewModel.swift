//
//  UnitBlogPostsViewModel.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2024/09/14.
//

import Foundation
import RxSwift
import RxRelay

class UnitBlogPostsViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrUnits = [MSelectItem]()
    var currentUnitIndex_ = BehaviorRelay(value: 0)
    var currentUnitIndex: Int { get { currentUnitIndex_.value } set { currentUnitIndex_.accept(newValue) } }
    var currentUnit: Int { arrUnits[currentUnitIndex].value }
    func next(_ delta: Int) {
        currentUnitIndex = (currentUnitIndex + delta + arrUnits.count) % arrUnits.count
    }

    init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        vmSettings = settings
        arrUnits = vmSettings.arrUnits
        super.init()
        currentUnitIndex = vmSettings.selectedUnitToIndex
    }
}
