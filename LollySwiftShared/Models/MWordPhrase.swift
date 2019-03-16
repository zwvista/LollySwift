//
//  WordsPhrases.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/03/16.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation

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
