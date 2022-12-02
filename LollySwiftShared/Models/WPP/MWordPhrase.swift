//
//  MWordPhrase.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/03/16.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation

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
class MWordPhrases: HasRecords {
    typealias RecordType = MWordPhrase
    dynamic var records = [MWordPhrase]()
}

@objcMembers
class MWordPhrase: NSObject, Codable {
    dynamic var ID = 0
    dynamic var WORDID = 0
    dynamic var PHRASEID = 0
    
    private static func getDataByWordPhrase(wordid: Int, phraseid: Int) async -> [MWordPhrase] {
        // SQL: SELECT * FROM WORDSPHRASES WHERE WORDID=? AND PHRASEID=?
        let url = "\(CommonApi.urlAPI)WORDSPHRASES?filter=WORDID,eq,\(wordid)&filter=PHRASEID,eq,\(phraseid)"
        return await RestApi.getRecords(MWordPhrases.self, url: url)
    }

    private static func create(item: MWordPhrase) async -> Int {
        // SQL: INSERT INTO WORDSPHRASES (WORDID, PHRASEID) VALUES (?,?)
        let url = "\(CommonApi.urlAPI)WORDSPHRASES"
        let id = Int(await RestApi.create(url: url, body: try! item.toJSONString()!))!
        print(id)
        return id
    }
    
    private static func delete(_ id: Int) async {
        // SQL: DELETE WORDSPHRASES WHERE ID=?
        let url = "\(CommonApi.urlAPI)WORDSPHRASES/\(id)"
        print(await RestApi.delete(url: url))
    }
    
    static func deleteByWordId(_ wordid: Int) async {
        // SQL: DELETE WORDSPHRASES WHERE WORDID=?
        let arr = await getPhrasesByWordId(wordid)
        if !arr.isEmpty {
            let ids = arr.map { String($0.ID) }.joined(separator: ",")
            let url = "\(CommonApi.urlAPI)WORDSPHRASES/\(ids)"
            print(await RestApi.delete(url: url))
        }
    }

    static func deleteByPhraseId(_ phraseid: Int) async {
        // SQL: DELETE WORDSPHRASES WHERE PHRASEID=?
        let arr = await getWordsByPhraseId(phraseid)
        if !arr.isEmpty {
            let ids = arr.map { String($0.ID) }.joined(separator: ",")
            let url = "\(CommonApi.urlAPI)WORDSPHRASES/\(ids)"
            print(await RestApi.delete(url: url))
        }
    }

    static func associate(wordid: Int, phraseid: Int) async {
        let arr = await getDataByWordPhrase(wordid: wordid, phraseid: phraseid)
        if arr.isEmpty {
            let item = MWordPhrase()
            item.WORDID = wordid
            item.PHRASEID = phraseid
            print(await create(item: item))
        }
    }
    
    static func dissociate(wordid: Int, phraseid: Int) async {
        let arr = await getDataByWordPhrase(wordid: wordid, phraseid: phraseid)
        for v in arr {
            await delete(v.ID)
        }
    }
    
    static func getPhrasesByWordId(_ wordid: Int) async -> [MLangPhrase] {
        // SQL: SELECT * FROM VPHRASESWORD WHERE WORDID=?
        let url = "\(CommonApi.urlAPI)VPHRASESWORD?filter=WORDID,eq,\(wordid)"
        return await RestApi.getRecords(MLangPhrases.self, url: url)
    }

    static func getWordsByPhraseId(_ phraseid: Int) async -> [MLangWord] {
        // SQL: SELECT * FROM VWORDSPHRASE WHERE PHRASEID=?
        let url = "\(CommonApi.urlAPI)VWORDSPHRASE?filter=PHRASEID,eq,\(phraseid)"
        return await RestApi.getRecords(MLangWords.self, url: url)
    }
}
