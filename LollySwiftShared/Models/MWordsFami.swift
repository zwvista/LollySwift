//
//  MWordsFami.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
class MWordsFami: NSObject, Codable {
    var ID = 0
    var USERID = 0
    var WORDID = 0
    var LEVEL = 0

    static func getDataByUserLangWord(userid: Int, wordid: Int) -> Observable<[MWordsFami]> {
        // SQL: SELECT * FROM WORDSFAMI WHERE USERID=? AND WORDID=?
        let url = "\(RestApi.url)WORDSFAMI?transform=1&filter[]=USERID,eq,\(userid)&filter[]=WORDID,eq,\(wordid)"
        return RestApi.getArray(url: url, keyPath: "WORDSFAMI")
    }

    static func update(item: MWordsFami) -> Observable<String> {
        // SQL: UPDATE WORDSFAMI SET USERID=?, WORDID=?, LEVEL=? WHERE ID=?
        let url = "\(RestApi.url)WORDSFAMI/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString(prettyPrint: false)!)
    }
    
    static func create(item: MWordsFami) -> Observable<Int> {
        // SQL: INSERT INTO WORDSFAMI (USERID, WORDID, LEVEL) VALUES (?,?,?)
        let url = "\(RestApi.url)WORDSFAMI"
        return RestApi.create(url: url, body: try! item.toJSONString(prettyPrint: false)!).map {
            return $0.toInt()!
        }
    }
    
    static func delete(_ id: Int) -> Observable<String> {
        // SQL: DELETE WORDSFAMI WHERE ID=?
        let url = "\(RestApi.url)WORDSFAMI/\(id)"
        return RestApi.delete(url: url)
    }
}
