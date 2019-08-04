//
//  MSelectItem.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2019/02/28.
//  Copyright © 2019 趙 偉. All rights reserved.
//

import Foundation

@objcMembers
class MSelectItem: NSObject {
    var value = 0
    var label = ""
    
    init(value: Int, label: String) {
        self.value = value
        self.label = label
        super.init()
    }
}

protocol MWordProtocol {
    var LANGID: Int { get set }
    var WORD: String { get set }
    var NOTE: String? { get set }
    var FAMIID: Int { get set }
    var LEVEL: Int { get set }
}

protocol MPhraseProtocol {
    var LANGID: Int { get set }
    var PHRASE: String { get set }
    var TRANSLATION: String? { get set }
}
