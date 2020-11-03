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
        let strs = item.PATTERN.split("／")
        arrPatternVariations = strs.enumerated().map {
            let o = MPatternVariation()
            o.index = $0.offset + 1
            o.variation = $0.element
            return o
        }
        itemEdit = MPatternEdit(x: item)
    }

    func splitPattern() {
        itemEdit.PATTERN.accept(Array(Set(arrPatternVariations.map { $0.variation })).joined(separator: ","))
    }

    func onOK() -> Observable<()> {
        let item = MPattern()
        itemEdit.save(to: item)
        item.PATTERNS_SPLIT = item.PATTERN
        return MPattern.mergePatterns(item: item)
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
