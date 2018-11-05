//
//  MLangPhrase.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/07.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
class MLangPhrase: NSObject, Codable {
    var ID = 0
    var LANGID = 0
    var PHRASE = ""
    var TRANSLATION: String?
    
    static func getDataByLang(_ langid: Int) -> Observable<[MLangPhrase]> {
        // SQL: SELECT PHRASE, TRANSLATION FROM LANGPHRASES WHERE LANGID = ?
        let url = "\(RestApi.url)LANGPHRASES?transform=1&filter=LANGID,eq,\(langid)"
        return RestApi.getArray(url: url, keyPath: "LANGPHRASES")
    }
    
    static func update(_ id: Int, item: MLangPhrase) -> Observable<String> {
        // SQL: UPDATE LANGPHRASES SET PHRASE=?, TRANSLATION=? WHERE ID=?
        let url = "\(RestApi.url)LANGPHRASES/\(id)"
        return RestApi.update(url: url, body: try! item.toJSONString(prettyPrint: false)!)
    }
    
    static func update(item: MLangPhrase) -> Observable<String> {
        // SQL: UPDATE LANGPHRASES SET PHRASE=?, TRANSLATION=? WHERE ID=?
        let url = "\(RestApi.url)LANGPHRASES/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString(prettyPrint: false)!)
    }

    static func create(item: MLangPhrase) -> Observable<String> {
        // SQL: INSERT INTO LANGPHRASES (LANGID, PHRASE, TRANSLATION) VALUES (?,?,?)
        let url = "\(RestApi.url)LANGPHRASES"
        return RestApi.create(url: url, body: try! item.toJSONString(prettyPrint: false)!)
    }
    
    static func delete(_ id: Int) -> Observable<String> {
        // SQL: DELETE LANGPHRASES WHERE ID=?
        let url = "\(RestApi.url)LANGPHRASES/\(id)"
        return RestApi.delete(url: url)
    }
}
