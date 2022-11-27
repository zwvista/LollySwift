//
//  MTextbook.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/06/09.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

@objcMembers
class MTextbooks: HasRecords {
    typealias RecordType = MTextbook
    dynamic var records = [MTextbook]()
}

@objcMembers
class MTextbook: NSObject, Codable {
    dynamic var ID = 0
    dynamic var LANGID = 0
    dynamic var TEXTBOOKNAME = ""
    dynamic var UNITS = ""
    dynamic var PARTS = ""
    dynamic var ISWEB = 0

    enum CodingKeys : String, CodingKey {
        case ID
        case LANGID
        case TEXTBOOKNAME = "NAME"
        case UNITS
        case PARTS
        case ISWEB
    }

    var arrUnits = [MSelectItem]()
    var arrParts = [MSelectItem]()
    func UNITSTR(_ unit: Int) -> String {
        arrUnits.first { $0.value == unit }!.label
    }
    func PARTSTR(_ part: Int) -> String {
        arrParts.first { $0.value == part }!.label
    }

    override var description: String { TEXTBOOKNAME }

    static func getDataByLang(_ langid: Int, arrUserSettings: [MUserSetting]) async -> [MTextbook] {
        // SQL: SELECT * FROM TEXTBOOKS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)TEXTBOOKS?filter=LANGID,eq,\(langid)"
        var o = await RestApi.getRecords(MTextbooks.self, url: url)
        o = o.filter { row in arrUserSettings.contains { $0.KIND == 11 && $0.ENTITYID == row.ID } }
        func f(units: String) -> [String] {
            if let m = #"UNITS,(\d+)"#.r!.findFirst(in: units) {
                let n = Int(m.group(at: 1)!)!
                return (1...n).map{ String($0) }
            } else if let m = #"PAGES,(\d+),(\d+)"#.r!.findFirst(in: units) {
                let (n1, n2) = (Int(m.group(at: 1)!)!, Int(m.group(at: 2)!)!)
                let n = (n1 + n2 - 1) / n2
                return (1...n).map { "\($0 * n2 - n2 + 1)~\($0 * n2)" }
            } else if let m = "CUSTOM,(.+)".r!.findFirst(in: units) {
                return m.group(at: 1)!.split(separator: ",").map { String($0) }
            } else {
                return []
            }
        }
        o.forEach { row in
            row.arrUnits = f(units: row.UNITS).enumerated().map { MSelectItem(value: $0.0 + 1, label: $0.1) }
            row.arrParts = row.PARTS.split(separator: ",").enumerated().map { MSelectItem(value: $0.0 + 1, label: String($0.1)) }
        }
        return o
    }

    static func update(item: MTextbook) async {
        // SQL: UPDATE TEXTBOOKS SET NAME=?, UNITS=?, PARTS=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)TEXTBOOKS/\(item.ID)"
        print(await RestApi.update(url: url, body: try! item.toJSONString()!))
    }

    static func create(item: MTextbook) async -> Int {
        // SQL: INSERT INTO TEXTBOOKS (ID, LANGID, NAME, UNITS, PARTS) VALUES (?,?,?,?,?)
        let url = "\(CommonApi.urlAPI)TEXTBOOKS"
        let id = Int(await RestApi.create(url: url, body: try! item.toJSONString()!))!
        print(id)
        return id
    }
}
