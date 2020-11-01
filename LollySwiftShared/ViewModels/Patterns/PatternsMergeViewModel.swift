//
//  PatternsMergeViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/11/01.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation

class PatternsMergeViewModel: NSObject {
    var arrPatterns: [MPattern]
    var arrPatternVariations: [MPatternVariation]
    var itemEdit = MPatternEdit()
        
    init(items: [MPattern]) {
        arrPatterns = items
        let strs = Array(Set(items.flatMap { $0.PATTERN.split("／") }))
        arrPatternVariations = strs.enumerated().map {
            let o = MPatternVariation()
            o.index = $0.offset
            o.variation = $0.element
            return o
        }
        itemEdit.NOTE.accept(items.map { $0.NOTE }.splitUsingCommaAndMerge())
        itemEdit.TAGS.accept(items.map { $0.TAGS }.splitUsingCommaAndMerge())
    }
    
    func mergePatterns() {
        itemEdit.PATTERN.accept(Array(Set(arrPatternVariations.map { $0.variation })).joined(separator: "／"))
    }

}
