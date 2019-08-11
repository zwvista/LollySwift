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
    
    private static func getDataByWordPhrase(wordid: Int, phraseid: Int) -> Observable<[MWordPhrase]> {
        // SQL: SELECT * FROM WORDSPHRASES WHERE WORDID=? AND PHRASEID=?
        let url = "\(CommonApi.url)WORDSPHRASES?filter=WORDID,eq,\(wordid)&filter=PHRASEID,eq,\(phraseid)"
        return RestApi.getRecords(url: url)
    }

    private static func create(item: MWordPhrase) -> Observable<Int> {
        // SQL: INSERT INTO WORDSPHRASES (WORDID, PHRASEID) VALUES (?,?)
        let url = "\(CommonApi.url)WORDSPHRASES"
        return RestApi.create(url: url, body: try! item.toJSONString(prettyPrint: false)!).map { $0.toInt()! }.do(onNext: { print($0) })
    }
    
    private static func delete(_ id: Int) -> Observable<()> {
        // SQL: DELETE WORDSPHRASES WHERE ID=?
        let url = "\(CommonApi.url)WORDSPHRASES/\(id)"
        return RestApi.delete(url: url).map { print($0) }
    }
    
    static func connect(wordid: Int, phraseid: Int) -> Observable<()> {
        return getDataByWordPhrase(wordid: wordid, phraseid: phraseid).flatMap { arr -> Observable<()> in
            if !arr.isEmpty {
                return Observable.empty()
            } else {
                let item = MWordPhrase()
                item.WORDID = wordid
                item.PHRASEID = phraseid
                return create(item: item).map { print($0) }
            }
        }
    }
    
    static func disconnect(wordid: Int, phraseid: Int) -> Observable<()> {
        return getDataByWordPhrase(wordid: wordid, phraseid: phraseid).flatMap { arr -> Observable<()> in
            var o = Observable.just(())
            for v in arr {
                o = o.concat(delete(v.ID))
            }
            return o
        }
    }
    
    static func getPhrasesByWord(wordid: Int) -> Observable<[MLangPhrase]> {
        // SQL: SELECT * FROM VPHRASESWORD WHERE WORDID=?
        let url = "\(CommonApi.url)VPHRASESWORD?filter=WORDID,eq,\(wordid)"
        return RestApi.getRecords(url: url)
    }

    static func getWordsByPhrase(phraseid: Int) -> Observable<[MLangWord]> {
        // SQL: SELECT * FROM VWORDSPHRASE WHERE PHRASEID=?
        let url = "\(CommonApi.url)VWORDSPHRASE?filter=PHRASEID,eq,\(phraseid)"
        return RestApi.getRecords(url: url)
    }
}
