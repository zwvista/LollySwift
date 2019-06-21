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
    var CORRECT = 0
    var TOTAL = 0

    private static func getDataByUserWord(userid: Int, wordid: Int) -> Observable<[MWordFami]> {
        // SQL: SELECT * FROM WORDSFAMI WHERE USERID=? AND WORDID=?
        let url = "\(CommonApi.url)WORDSFAMI?filter=USERID,eq,\(userid)&filter=WORDID,eq,\(wordid)"
        return RestApi.getRecords(url: url)
    }

    private static func update(item: MWordFami) -> Observable<()> {
        // SQL: UPDATE WORDSFAMI SET USERID=?, WORDID=?, LEVEL=? WHERE ID=?
        let url = "\(CommonApi.url)WORDSFAMI/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString(prettyPrint: false)!).map { print($0) }
    }
    
    private static func create(item: MWordFami) -> Observable<Int> {
        // SQL: INSERT INTO WORDSFAMI (USERID, WORDID, LEVEL) VALUES (?,?,?)
        let url = "\(CommonApi.url)WORDSFAMI"
        return RestApi.create(url: url, body: try! item.toJSONString(prettyPrint: false)!).map { $0.toInt()! }.do(onNext: { print($0) })
    }
    
    static func delete(_ id: Int) -> Observable<()> {
        // SQL: DELETE WORDSFAMI WHERE ID=?
        let url = "\(CommonApi.url)WORDSFAMI/\(id)"
        return RestApi.delete(url: url).map { print($0) }
    }
    
    static func update(wordid: Int, level: Int) -> Observable<()> {
        let userid = CommonApi.userid
        return getDataByUserWord(userid: userid, wordid: wordid).flatMap { arr -> Observable<()> in
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
            } else if level == 0 && arr[0].CORRECT == 0 && arr[0].TOTAL == 0  {
                return delete(arr[0].ID).map { print($0) }
            } else {
                item.ID = arr[0].ID
                item.CORRECT = arr[0].CORRECT
                item.TOTAL = arr[0].TOTAL
                return update(item: item)
            }
        }
    }
    
    static func update(wordid: Int, isCorrect: Bool) -> Observable<MWordFami> {
        let userid = CommonApi.userid
        return getDataByUserWord(userid: userid, wordid: wordid).flatMap { arr -> Observable<MWordFami> in
            let item = MWordFami()
            item.USERID = userid
            item.WORDID = wordid
            if arr.isEmpty {
                item.CORRECT = isCorrect ? 1 : 0
                item.TOTAL = 1
                return create(item: item).map { print($0); return item }
            } else {
                item.ID = arr[0].ID
                item.LEVEL = arr[0].LEVEL
                item.CORRECT = arr[0].CORRECT + (isCorrect ? 1 : 0)
                item.TOTAL = arr[0].TOTAL + 1
                return update(item: item).map { item }
            }
        }
    }
    
    static func clearAccuracy(wordid: Int) -> Observable<()> {
        let userid = CommonApi.userid
        return getDataByUserWord(userid: userid, wordid: wordid).flatMap { arr -> Observable<()> in
            if arr.isEmpty {
                return Observable.empty()
            } else if arr[0].LEVEL == 0 {
                return delete(arr[0].ID)
            } else {
                let item = MWordFami()
                item.USERID = userid
                item.WORDID = wordid
                item.ID = arr[0].ID
                item.LEVEL = arr[0].LEVEL
                item.CORRECT = 0
                item.TOTAL = 0
                return update(item: item)
            }
        }
    }
}
