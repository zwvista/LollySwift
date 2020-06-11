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
    var PATTERNID = 0
    var LANGID = 0
    var PATTERN = ""
    var NOTE: String?
    var ID = 0
    var SEQNUM = 0
    var PHRASEID = 0
    var PHRASE = ""
    var TRANSLATION: String?

    override init() {
    }
    
    func copy(from x: MPatternPhrase) {
        PATTERNID = x.PATTERNID
        LANGID = x.LANGID
        PATTERN = x.PATTERN
        NOTE = x.NOTE
        ID = x.ID
        SEQNUM = x.SEQNUM
        PHRASEID = x.PHRASEID
        PHRASE = x.PHRASE
        TRANSLATION = x.TRANSLATION
    }

    static func getDataByPatternId(_ patternid: Int) -> Observable<[MPatternPhrase]> {
        // SQL: SELECT * FROM VPATTERNSPHRASES WHERE PATTERNID=?
        let url = "\(CommonApi.url)VPATTERNSPHRASES?filter=PATTERNID,eq,\(patternid)"
        return RestApi.getRecords(url: url)
    }
    
    static func getDataByPatternIdPhraseId(patternid: Int, phraseid: Int) -> Observable<[MPatternPhrase]> {
        // SQL: SELECT * FROM VPATTERNSPHRASES WHERE PATTERNID=? AND PHRASEID=?
        let url = "\(CommonApi.url)VPATTERNSPHRASES?filter=PATTERNID,eq,\(patternid)&filter=PHRASEID,eq,\(phraseid)"
        return RestApi.getRecords(url: url)
    }
    
    static func getDataByPhraseId(_ phraseid: Int) -> Observable<[MPatternPhrase]> {
        // SQL: SELECT * FROM VPATTERNSPHRASES WHERE PHRASEID=?
        let url = "\(CommonApi.url)VPATTERNSPHRASES?filter=PHRASEID,eq,\(phraseid)"
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
        let url = "\(CommonApi.url)PATTERNSPHRASES/\(id)"
        return RestApi.delete(url: url).map { print($0) }
    }
    
    static func deleteByPhraseId(_ phraseid: Int) -> Observable<()> {
        // SQL: DELETE PATTERNSPHRASES WHERE PHRASEID=?
        getDataByPhraseId(phraseid).flatMap { arr -> Observable<()> in
            if arr.isEmpty {
                return Observable.empty()
            } else {
                let ids = arr.map { $0.ID.description }.joined(separator: ",")
                let url = "\(CommonApi.url)PATTERNSPHRASES/\(ids)"
                return RestApi.delete(url: url).map { print($0) }
            }
        }
    }

    static func connect(patternid: Int, phraseid: Int) -> Observable<()> {
        getDataByPatternIdPhraseId(patternid: patternid, phraseid: phraseid).flatMap { arr -> Observable<()> in
            return !arr.isEmpty ? Observable.empty() : getDataByPatternId(patternid).flatMap { arr2 -> Observable<()> in
                let item = MPatternPhrase()
                item.PATTERNID = patternid
                item.PHRASEID = phraseid
                item.SEQNUM = arr2.count + 1
                return create(item: item).map { print($0) }
            }
        }
    }
    
    static func disconnect(patternid: Int, phraseid: Int) -> Observable<()> {
        getDataByPatternIdPhraseId(patternid: patternid, phraseid: phraseid).flatMap { arr -> Observable<()> in
            var o = Observable.just(())
            for v in arr {
                o = o.concat(delete(v.ID))
            }
            return o
        }
    }
}
