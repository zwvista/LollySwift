//
//  MWordFami.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
class MWordFami: NSObject, Codable {
    var ID = 0
    var USERID = 0
    var WORDID = 0
    var LEVEL = 0

    static let userid = 1

    private static func getDataByUserWord(userid: Int, wordid: Int) -> Observable<[MWordFami]> {
        // SQL: SELECT * FROM WORDSFAMI WHERE USERID=? AND WORDID=?
        let url = "\(RestApi.url)WORDSFAMI?transform=1&filter[]=USERID,eq,\(userid)&filter[]=WORDID,eq,\(wordid)"
        return RestApi.getArray(url: url, keyPath: "WORDSFAMI")
    }

    private static func update(item: MWordFami) -> Observable<String> {
        // SQL: UPDATE WORDSFAMI SET USERID=?, WORDID=?, LEVEL=? WHERE ID=?
        let url = "\(RestApi.url)WORDSFAMI/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString(prettyPrint: false)!)
    }
    
    private static func create(item: MWordFami) -> Observable<Int> {
        // SQL: INSERT INTO WORDSFAMI (USERID, WORDID, LEVEL) VALUES (?,?,?)
        let url = "\(RestApi.url)WORDSFAMI"
        return RestApi.create(url: url, body: try! item.toJSONString(prettyPrint: false)!).map {
            return $0.toInt()!
        }
    }
    
    private static func delete(_ id: Int) -> Observable<String> {
        // SQL: DELETE WORDSFAMI WHERE ID=?
        let url = "\(RestApi.url)WORDSFAMI/\(id)"
        return RestApi.delete(url: url)
    }
    
    static func update(wordid: Int, level: Int) -> Observable<()> {
        return getDataByUserWord(userid: 1, wordid: wordid).flatMap { arr -> Observable<()> in
            let item = MWordFami()
            item.USERID = userid
            item.WORDID = wordid
            item.LEVEL = level
            if arr.isEmpty {
                if level == 0 {
                    return Observable.empty()
                } else {
                    return create(item: item).map { print($0) }
                }
            } else {
                let id = arr[0].ID
                if level == 0 {
                    return delete(id).map { print($0) }
                } else {
                    item.ID = id
                    return update(item: item).map { print($0) }
                }
            }
        }
    }
}
