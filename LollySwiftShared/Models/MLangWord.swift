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
class MLangWord: NSObject, Codable {
    var ID = 0
    var LANGID = 0
    var WORD = ""
    var LEVEL = 0
    
    static func getDataByLang(_ langid: Int) -> Observable<[MLangWord]> {
        // SQL: SELECT LANGID, WORD FROM LANGWORDS WHERE LANGID = ?
        let url = "\(RestApi.url)LANGWORDS?transform=1&filter=LANGID,eq,\(langid)"
        return RestApi.getArray(url: url, keyPath: "LANGWORDS", type: MLangWord.self)
    }
    
    static func update(_ id: Int, word: String) -> Observable<String> {
        // SQL: UPDATE LANGWORDS SET WORD=? WHERE ID=?
        let url = "\(RestApi.url)LANGWORDS/\(id)"
        let body = "WORD=\(word)"
        return RestApi.update(url: url, body: body)
    }
    
    static func create(item: MLangWord) -> Observable<String> {
        // SQL: INSERT INTO LANGWORDS (LANGID, WORD) VALUES (?,?)
        let url = "\(RestApi.url)LANGWORDS"
        return RestApi.create(url: url, body: try! item.toJSONString()!)
    }
    
    static func delete(_ id: Int) -> Observable<String> {
        // SQL: DELETE LANGWORDS WHERE ID=?
        let url = "\(RestApi.url)LANGWORDS/\(id)"
        return RestApi.delete(url: url)
    }
}
