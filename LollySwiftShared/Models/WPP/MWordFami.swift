//
//  MWordFami.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/07/05.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

@objcMembers
class MWordFamis: HasRecords, @unchecked Sendable {
    typealias RecordType = MWordFami
    dynamic var records = [MWordFami]()
}

@objcMembers
class MWordFami: NSObject, Codable, @unchecked Sendable {
    dynamic var ID = 0
    dynamic var USERID = ""
    dynamic var WORDID = 0
    dynamic var CORRECT = 0
    dynamic var TOTAL = 0

    static func getDataByWord(wordid: Int) async -> [MWordFami] {
        // SQL: SELECT * FROM WORDSFAMI WHERE USERID=? AND WORDID=?
        let url = "\(CommonApi.urlAPI)WORDSFAMI?filter=USERID,eq,\(globalUser.userid)&filter=WORDID,eq,\(wordid)"
        return await RestApi.getRecords(MWordFamis.self, url: url)
    }

    private static func update(item: MWordFami) async {
        // SQL: UPDATE WORDSFAMI SET USERID=?, WORDID=?, WHERE ID=?
        let url = "\(CommonApi.urlAPI)WORDSFAMI/\(item.ID)"
        print(await RestApi.update(url: url, body: item.toParameters(isSP: false)))
    }

    private static func create(item: MWordFami) async -> Int {
        // SQL: INSERT INTO WORDSFAMI (USERID, WORDID) VALUES (?,?)
        let url = "\(CommonApi.urlAPI)WORDSFAMI"
        let id = Int(await RestApi.create(url: url, body: item.toParameters(isSP: false)))!
        print(id)
        return id
    }

    static func delete(_ id: Int) async {
        // SQL: DELETE WORDSFAMI WHERE ID=?
        let url = "\(CommonApi.urlAPI)WORDSFAMI/\(id)"
        print(await RestApi.delete(url: url))
    }

    static func update(wordid: Int, isCorrect: Bool) async -> MWordFami {
        let arr = await getDataByWord(wordid: wordid)
        let item = MWordFami()
        item.USERID = globalUser.userid
        item.WORDID = wordid
        if arr.isEmpty {
            item.CORRECT = isCorrect ? 1 : 0
            item.TOTAL = 1
            print(await create(item: item))
        } else {
            item.ID = arr[0].ID
            item.CORRECT = arr[0].CORRECT + (isCorrect ? 1 : 0)
            item.TOTAL = arr[0].TOTAL + 1
            await update(item: item)
        }
        return item
    }
}
