//
//  PatternsSplitViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/11/01.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class PatternsSplitViewModel: NSObject {
    var arrPatterns = [MPattern]()
    var arrPatternVariations = [MPatternVariation]()
    var itemEdit: MPatternEdit
    
    init(item: MPattern) {
        arrPatterns = [item]
        let strs = item.PATTERN.split(separator: "／")
        arrPatternVariations = strs.enumerated().map {
            let o = MPatternVariation()
            o.index = $0.offset + 1
            o.variation = String($0.element)
            return o
        }
        itemEdit = MPatternEdit(x: item)
        super.init()
        mergeVariations()
    }

    func mergeVariations() {
        itemEdit.PATTERN.accept(arrPatternVariations.map(\.variation).unique.joined(separator: ","))
    }

    func reindexVariations(complete: (Int) -> ()) {
        for i in 1...arrPatternVariations.count {
            let item = arrPatternVariations[i - 1]
            guard item.index != i else {continue}
            item.index = i
            complete(i - 1)
        }
    }

    func onOK() async {
        let item = MPattern()
        itemEdit.save(to: item)
        item.PATTERNS_SPLIT = item.PATTERN
        await MPattern.mergePatterns(item: item)
    }
}
