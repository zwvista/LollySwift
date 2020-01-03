//
//  MPatternPhrase.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/01/02.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
class MPatternPhrase: NSObject, Codable {
    var ID = 0
    var PATTERNID = 0
    var PATTERN = ""
    var SEQNUM = 0
    var PHRASEID = 0
    var PHRASE = ""
    var TRANSLATION: String?

    override init() {
    }
    
    func copy(from x: MPatternPhrase) {
        ID = x.ID
        PATTERNID = x.PATTERNID
        PATTERN = x.PATTERN
        SEQNUM = x.SEQNUM
        PHRASEID = x.PHRASEID
        PHRASE = x.PHRASE
        TRANSLATION = x.TRANSLATION
    }

    static func getDataByPattern(_ patternid: Int) -> Observable<[MPatternPhrase]> {
        // SQL: SELECT * FROM VPATTERNSPHRASES WHERE PATTERNID=?
        let url = "\(CommonApi.url)VPATTERNSPHRASES?filter=PATTERNID,eq,\(patternid)"
        return RestApi.getRecords(url: url)
    }
    
    static func getDataById(_ id: Int) -> Observable<[MPatternPhrase]> {
        // SQL: SELECT * FROM VPATTERNSPHRASES WHERE ID=?
        let url = "\(CommonApi.url)VPATTERNSPHRASES?filter=ID,eq,\(id)"
        return RestApi.getRecords(url: url)
    }
    
    static func update(_ id: Int, seqnum: Int) -> Observable<()> {
        // SQL: UPDATE PATTERNSPHRASES SET SEQNUM=? WHERE ID=?
        let url = "\(CommonApi.url)PATTERNSPHRASES/\(id)"
        let body = "SEQNUM=\(seqnum)"
        return RestApi.update(url: url, body: body).map { print($0) }
    }

    static func update(item: MPatternPhrase) -> Observable<()> {
        // SQL: UPDATE PATTERNSPHRASES SET PATTERNID=? AND PHRASEID=? WHERE ID=?
        let url = "\(CommonApi.url)PATTERNSPHRASES/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString(prettyPrint: false)!).map { print($0) }
    }

    static func create(item: MPatternPhrase) -> Observable<Int> {
        // SQL: INSERT INTO PATTERNSPHRASES (PATTERNID, SEQNUM, PHRASEID) VALUES (?,?,?)
        let url = "\(CommonApi.url)PATTERNSPHRASES"
        return RestApi.create(url: url, body: try! item.toJSONString(prettyPrint: false)!).map { $0.toInt()! }.do(onNext: { print($0) })
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        // SQL: DELETE PATTERNSPHRASES WHERE ID=?
        let url = "\(CommonApi.url)PATTERNSPhraseS/\(id)"
        return RestApi.delete(url: url).map { print($0) }
    }
}
