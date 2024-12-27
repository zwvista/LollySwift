//
//  UnitBlogPostsViewModel.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2024/09/14.
//

import Foundation

@MainActor
class UnitBlogPostsViewModel: NSObject, ObservableObject {
    var vmSettings: SettingsViewModel
    @Published var arrUnits = [MSelectItem]()
    @Published var currentUnitIndex = 0
    var selectedUnit: Int { arrUnits[currentUnitIndex].value }
    func next(_ delta: Int) {
        currentUnitIndex = (currentUnitIndex + delta + arrUnits.count) % arrUnits.count
    }

    init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        vmSettings = settings
        arrUnits = vmSettings.arrUnits
        currentUnitIndex = vmSettings.selectedUnitToIndex
        super.init()
    }
}
