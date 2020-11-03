//
//  PatternsMergeViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/11/01.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class PatternsMergeViewModel: NSObject {
    var arrPatterns: [MPattern]
    var arrPatternVariations: [MPatternVariation]
    var itemEdit = MPatternEdit()
        
    init(items: [MPattern]) {
        arrPatterns = items
        let strs = Array(Set(items.flatMap { $0.PATTERN.split("／") }))
        arrPatternVariations = strs.enumerated().map {
            let o = MPatternVariation()
            o.index = $0.offset + 1
            o.variation = $0.element
            return o
        }
        super.init()
        mergePatterns()
        itemEdit.NOTE.accept(items.map { $0.NOTE }.splitUsingCommaAndMerge())
        itemEdit.TAGS.accept(items.map { $0.TAGS }.splitUsingCommaAndMerge())
    }
    
    func mergePatterns() {
        itemEdit.PATTERN.accept(Array(Set(arrPatternVariations.map { $0.variation })).joined(separator: "／"))
    }
    
    func onOK() -> Observable<()> {
        let item = MPattern()
        itemEdit.save(to: item)
        item.IDS_MERGE = arrPatterns.sorted { $0.ID < $1.ID }.map { $0.ID.toString }.joined(separator: ",")
        return MPattern.mergePatterns(item: item)
    }
    
    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
