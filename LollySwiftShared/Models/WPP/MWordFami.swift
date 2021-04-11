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

    static func getDataByUserWord(wordid: Int) -> Observable<[MWordFami]> {
        // SQL: SELECT * FROM WORDSFAMI WHERE USERID=? AND WORDID=?
        let url = "\(CommonApi.urlAPI)WORDSFAMI?filter=USERID,eq,\(CommonApi.userid)&filter=WORDID,eq,\(wordid)"
        return RestApi.getRecords(url: url)
    }

    private static func update(item: MWordFami) -> Observable<()> {
        // SQL: UPDATE WORDSFAMI SET USERID=?, WORDID=?, WHERE ID=?
        let url = "\(CommonApi.urlAPI)WORDSFAMI/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString()!).map { print($0) }
    }
    
    private static func create(item: MWordFami) -> Observable<Int> {
        // SQL: INSERT INTO WORDSFAMI (USERID, WORDID) VALUES (?,?)
        let url = "\(CommonApi.urlAPI)WORDSFAMI"
        return RestApi.create(url: url, body: try! item.toJSONString()!).map { $0.toInt()! }.do(onNext: { print($0) })
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        // SQL: DELETE WORDSFAMI WHERE ID=?
        let url = "\(CommonApi.urlAPI)WORDSFAMI/\(id)"
        return RestApi.delete(url: url).map { print($0) }
    }
    
    static func update(wordid: Int, isCorrect: Bool) -> Observable<MWordFami> {
        return getDataByUserWord(wordid: wordid).flatMap { arr -> Observable<MWordFami> in
            let item = MWordFami()
            item.USERID = CommonApi.userid
            item.WORDID = wordid
            if arr.isEmpty {
                item.CORRECT = isCorrect ? 1 : 0
                item.TOTAL = 1
                return create(item: item).map { print($0); return item }
            } else {
                item.ID = arr[0].ID
                item.CORRECT = arr[0].CORRECT + (isCorrect ? 1 : 0)
                item.TOTAL = arr[0].TOTAL + 1
                return update(item: item).map { item }
            }
        }
    }
}
