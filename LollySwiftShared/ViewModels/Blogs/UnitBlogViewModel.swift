//
//  UnitBlogViewModel.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2024/09/14.
//

import Foundation

@MainActor
class UnitBlogViewModel: NSObject, ObservableObject {
    var vmSettings: SettingsViewModel
    @Published var arrUnits = [MSelectItem]()
    @Published var currentUnitIndex = 0
    var selectedUnit: Int {
        return arrUnits[currentUnitIndex].value
    }
    func next(_ delta: Int) {
        currentUnitIndex = (currentUnitIndex + delta + arrUnits.count) % arrUnits.count
    }

    init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> Void) {
        vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        arrUnits = vmSettings.arrUnits
        currentUnitIndex = vmSettings.selectedUnitToIndex
        super.init()
    }
}
