//
//  MWordPhrase.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/03/16.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift

protocol MWordProtocol {
    var LANGID: Int { get set }
    var WORDID: Int { get }
    var WORD: String { get set }
    var NOTE: String { get set }
    var FAMIID: Int { get set }
}

protocol MPhraseProtocol {
    var LANGID: Int { get set }
    var PHRASEID: Int { get }
    var PHRASE: String { get set }
    var TRANSLATION: String { get set }
}

@objcMembers
class MWordPhrase: NSObject, Codable {
    dynamic var ID = 0
    dynamic var WORDID = 0
    dynamic var PHRASEID = 0
    
    private static func getDataByWordPhrase(wordid: Int, phraseid: Int) -> Single<[MWordPhrase]> {
        // SQL: SELECT * FROM WORDSPHRASES WHERE WORDID=? AND PHRASEID=?
        let url = "\(CommonApi.urlAPI)WORDSPHRASES?filter=WORDID,eq,\(wordid)&filter=PHRASEID,eq,\(phraseid)"
        return RestApi.getRecords(url: url)
    }

    private static func create(item: MWordPhrase) -> Single<Int> {
        // SQL: INSERT INTO WORDSPHRASES (WORDID, PHRASEID) VALUES (?,?)
        let url = "\(CommonApi.urlAPI)WORDSPHRASES"
        return RestApi.create(url: url, body: try! item.toJSONString()!).map { Int($0)! }.do(onSuccess: { print($0) })
    }
    
    private static func delete(_ id: Int) -> Single<()> {
        // SQL: DELETE WORDSPHRASES WHERE ID=?
        let url = "\(CommonApi.urlAPI)WORDSPHRASES/\(id)"
        return RestApi.delete(url: url).map { print($0) }
    }
    
    static func deleteByWordId(_ wordid: Int) -> Single<()> {
        // SQL: DELETE WORDSPHRASES WHERE WORDID=?
        return getPhrasesByWordId(wordid).flatMap { arr in
            if !arr.isEmpty {
                return Single.just(())
            } else {
                let ids = arr.map { String($0.ID) }.joined(separator: ",")
                let url = "\(CommonApi.urlAPI)WORDSPHRASES/\(ids)"
                return RestApi.delete(url: url).map { print($0) }
            }
        }
    }

    static func deleteByPhraseId(_ phraseid: Int) -> Single<()> {
        // SQL: DELETE WORDSPHRASES WHERE PHRASEID=?
        getWordsByPhraseId(phraseid).flatMap { arr in
            if arr.isEmpty {
                return Single.just(())
            } else {
                let ids = arr.map { String($0.ID) }.joined(separator: ",")
                let url = "\(CommonApi.urlAPI)WORDSPHRASES/\(ids)"
                return RestApi.delete(url: url).map { print($0) }
            }
        }
    }

    static func associate(wordid: Int, phraseid: Int) -> Single<()> {
        getDataByWordPhrase(wordid: wordid, phraseid: phraseid).flatMap { arr in
            if !arr.isEmpty {
                return Single.just(())
            } else {
                let item = MWordPhrase()
                item.WORDID = wordid
                item.PHRASEID = phraseid
                return create(item: item).map { print($0) }
            }
        }
    }
    
    static func dissociate(wordid: Int, phraseid: Int) -> Single<()> {
        getDataByWordPhrase(wordid: wordid, phraseid: phraseid).flatMap { arr in
            var o = Single.just(())
            for v in arr {
                o = o.flatMap { delete(v.ID) }
            }
            return o
        }
    }
    
    static func getPhrasesByWordId(_ wordid: Int) -> Single<[MLangPhrase]> {
        // SQL: SELECT * FROM VPHRASESWORD WHERE WORDID=?
        let url = "\(CommonApi.urlAPI)VPHRASESWORD?filter=WORDID,eq,\(wordid)"
        return RestApi.getRecords(url: url)
    }

    static func getWordsByPhraseId(_ phraseid: Int) -> Single<[MLangWord]> {
        // SQL: SELECT * FROM VWORDSPHRASE WHERE PHRASEID=?
        let url = "\(CommonApi.urlAPI)VWORDSPHRASE?filter=PHRASEID,eq,\(phraseid)"
        return RestApi.getRecords(url: url)
    }
}
