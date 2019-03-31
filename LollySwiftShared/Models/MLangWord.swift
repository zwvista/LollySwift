//
//  MLangWord.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
class MLangWord: NSObject, Codable, MWordProtocol {
    var ID = 0
    var LANGID = 0
    var WORD = ""
    var NOTE: String?
    var FAMIID = 0
    var LEVEL = 0

    var WORDNOTE: String {
        return WORD + ((NOTE ?? "").isEmpty ? "" : "(\(NOTE!))")
    }

    override init() {
    }
    
    init(unititem: MUnitWord) {
        ID = unititem.WORDID
        LANGID = unititem.LANGID
        WORD = unititem.WORD
        NOTE = unititem.NOTE
        super.init()
    }

    func combineNote(_ note: String?) -> Bool {
        let oldNote = NOTE
        if !(note ?? "").isEmpty {
            if (NOTE ?? "").isEmpty {
                NOTE = note
            } else {
                var arr = NOTE!.split(",")
                if !arr.contains(note!) {
                    arr.append(note!)
                    NOTE = arr.joined(separator: ",")
                }
            }
        }
        return oldNote != NOTE
    }

    static func getDataByLang(_ langid: Int) -> Observable<[MLangWord]> {
        // SQL: SELECT * FROM LANGWORDS WHERE LANGID=?
        let url = "\(CommonApi.url)VLANGWORDS?transform=1&filter=LANGID,eq,\(langid)&order=WORD"
        return RestApi.getArray(url: url, keyPath: "VLANGWORDS")
    }

    static func getDataByLangWord(langid: Int, word: String) -> Observable<[MLangWord]> {
        // SQL: SELECT * FROM LANGWORDS WHERE LANGID=? AND WORD=?
        let url = "\(CommonApi.url)VLANGWORDS?transform=1&filter[]=LANGID,eq,\(langid)&filter[]=WORD,eq,\(word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
        // Api is case insensitive
        return RestApi.getArray(url: url, keyPath: "VLANGWORDS").map { $0.filter { $0.WORD == word } }
    }

    static func getDataById(_ id: Int) -> Observable<[MLangWord]> {
        // SQL: SELECT * FROM LANGWORDS WHERE ID=?
        let url = "\(CommonApi.url)VLANGWORDS?transform=1&filter=ID,eq,\(id)"
        return RestApi.getArray(url: url, keyPath: "VLANGWORDS")
    }
    
    static func update(_ id: Int, note: String) -> Observable<()> {
        // SQL: UPDATE LANGWORDS SET NOTE=? WHERE ID=?
        let url = "\(CommonApi.url)LANGWORDS/\(id)"
        let body = "NOTE=\(note)"
        return RestApi.update(url: url, body: body).map { print($0) }
    }

    static func update(item: MLangWord) -> Observable<()> {
        // SQL: UPDATE LANGWORDS SET WORD=?, NOTE=? WHERE ID=?
        let url = "\(CommonApi.url)LANGWORDS/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString(prettyPrint: false)!).map { print($0) }
    }

    static func create(item: MLangWord) -> Observable<Int> {
        // SQL: INSERT INTO LANGWORDS (LANGID, WORD) VALUES (?,?)
        let url = "\(CommonApi.url)LANGWORDS"
        return RestApi.create(url: url, body: try! item.toJSONString(prettyPrint: false)!).map {
            let id = $0.toInt()!
            print(id)
            return id
        }
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        // SQL: DELETE LANGWORDS WHERE ID=?
        let url = "\(CommonApi.url)LANGWORDS/\(id)"
        return RestApi.delete(url: url).map { print($0) }
    }
}
