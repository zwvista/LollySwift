//
//  MWordPhrase.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/03/16.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
class MWordPhrase: NSObject, Codable {
    var ID = 0
    var WORDID = 0
    var PHRASEID = 0
    
    static func getPhrasesByWord(wordid: Int) -> Observable<[MWordPhrase]> {
        // SQL: SELECT * FROM WORDSPHRASES WHERE WORDID=?
        let url = "\(CommonApi.url)WORDSPHRASES?filter=WORDID,eq,\(wordid)"
        return RestApi.getRecords(url: url)
    }

    static func getWordsByPhrase(phraseid: Int) -> Observable<[MWordPhrase]> {
        // SQL: SELECT * FROM WORDSPHRASES WHERE PHRASEID=?
        let url = "\(CommonApi.url)WORDSPHRASES?filter=PHRASEID,eq,\(phraseid)"
        return RestApi.getRecords(url: url)
    }
}
