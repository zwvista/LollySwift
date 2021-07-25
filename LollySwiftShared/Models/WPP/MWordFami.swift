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
    dynamic var ID = 0
    dynamic var USERID = ""
    dynamic var WORDID = 0
    dynamic var CORRECT = 0
    dynamic var TOTAL = 0

    static func getDataByWord(wordid: Int) -> Single<[MWordFami]> {
        // SQL: SELECT * FROM WORDSFAMI WHERE USERID=? AND WORDID=?
        let url = "\(CommonApi.urlAPI)WORDSFAMI?filter=USERID,eq,\(globalUser.userid)&filter=WORDID,eq,\(wordid)"
        return RestApi.getRecords(url: url)
    }

    private static func update(item: MWordFami) -> Completable {
        // SQL: UPDATE WORDSFAMI SET USERID=?, WORDID=?, WHERE ID=?
        let url = "\(CommonApi.urlAPI)WORDSFAMI/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString()!).flatMapCompletable { print($0); return Completable.empty() }
    }
    
    private static func create(item: MWordFami) -> Single<Int> {
        // SQL: INSERT INTO WORDSFAMI (USERID, WORDID) VALUES (?,?)
        let url = "\(CommonApi.urlAPI)WORDSFAMI"
        return RestApi.create(url: url, body: try! item.toJSONString()!).map { Int($0)! }.do(onSuccess: { print($0) })
    }
    
    static func delete(_ id: Int) -> Completable {
        // SQL: DELETE WORDSFAMI WHERE ID=?
        let url = "\(CommonApi.urlAPI)WORDSFAMI/\(id)"
        return RestApi.delete(url: url).flatMapCompletable { print($0); return Completable.empty() }
    }
    
    static func update(wordid: Int, isCorrect: Bool) -> Single<MWordFami> {
        return getDataByWord(wordid: wordid).flatMap { arr -> Single<MWordFami> in
            let item = MWordFami()
            item.USERID = globalUser.userid
            item.WORDID = wordid
            if arr.isEmpty {
                item.CORRECT = isCorrect ? 1 : 0
                item.TOTAL = 1
                return create(item: item).map { print($0); return item }
            } else {
                item.ID = arr[0].ID
                item.CORRECT = arr[0].CORRECT + (isCorrect ? 1 : 0)
                item.TOTAL = arr[0].TOTAL + 1
                return update(item: item).andThen(Single.just(item))
            }
        }
    }
}
