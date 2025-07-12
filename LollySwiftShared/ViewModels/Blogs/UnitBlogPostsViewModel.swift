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
    var selectedUnitIndex_ = BehaviorRelay(value: 0)
    var selectedUnitIndex: Int { get { selectedUnitIndex_.value } set { selectedUnitIndex_.accept(newValue) } }
    var selectedUnit: Int { arrUnits[selectedUnitIndex].value }
    func next(_ delta: Int) {
        selectedUnitIndex = (selectedUnitIndex + delta + arrUnits.count) % arrUnits.count
    }

    init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        vmSettings = settings
        arrUnits = vmSettings.arrUnits
        super.init()
        selectedUnitIndex = vmSettings.selectedUnitToIndex
    }
}
