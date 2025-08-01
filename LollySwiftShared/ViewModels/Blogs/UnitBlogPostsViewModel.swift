//
//  UnitBlogPostsViewModel.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2024/09/14.
//

import Foundation

@MainActor
class UnitBlogPostsViewModel: NSObject, ObservableObject {

    @Published var arrUnits = [MSelectItem]()
    @Published var selectedUnitIndex = 0
    var selectedUnit: Int { arrUnits[selectedUnitIndex].value }
    func next(_ delta: Int) {
        selectedUnitIndex = (selectedUnitIndex + delta + arrUnits.count) % arrUnits.count
    }

    override init() {
        arrUnits = vmSettings.arrUnits
        selectedUnitIndex = vmSettings.selectedUnitToIndex
        super.init()
    }
}
