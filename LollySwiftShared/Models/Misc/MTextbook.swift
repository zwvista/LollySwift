//
//  MTextbook.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/06/09.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

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

    static func getDataByLang(_ langid: Int, arrUserSettings: [MUserSetting]) -> Single<[MTextbook]> {
        // SQL: SELECT * FROM TEXTBOOKS WHERE LANGID=?
        let url = "\(CommonApi.urlAPI)TEXTBOOKS?filter=LANGID,eq,\(langid)"
        var o: Single<[MTextbook]> = RestApi.getRecords(url: url)
        o = o.map { $0.filter { row in arrUserSettings.contains { $0.KIND == 11 && $0.ENTITYID == row.ID } } }
        func f(units: String) -> [String] {
            if let m = units.firstMatch(of: /UNITS,(\d+)/) {
                let n = Int(m.1)!
                return (1...n).map{ String($0) }
            } else if let m = units.firstMatch(of: /PAGES,(\d+),(\d+)/) {
                let (n1, n2) = (Int(m.1)!, Int(m.2)!)
                let n = (n1 + n2 - 1) / n2
                return (1...n).map { "\($0 * n2 - n2 + 1)~\($0 * n2)" }
            } else if let m = units.firstMatch(of: /CUSTOM,(.+)/) {
                return m.1.split(separator: ",").map { String($0) }
            } else {
                return []
            }
        }
        return o.do(onSuccess: { arr in
            arr.forEach { row in
                row.arrUnits = f(units: row.UNITS).enumerated().map { MSelectItem(value: $0.0 + 1, label: $0.1) }
                row.arrParts = row.PARTS.split(separator: ",").enumerated().map { MSelectItem(value: $0.0 + 1, label: String($0.1)) }
            }
        })
    }

    static func update(item: MTextbook) -> Single<()> {
        // SQL: UPDATE TEXTBOOKS SET NAME=?, UNITS=?, PARTS=? WHERE ID=?
        let url = "\(CommonApi.urlAPI)TEXTBOOKS/\(item.ID)"
        return RestApi.update(url: url, body: item.toParameters(isSP: false)).map { print($0) }
    }

    static func create(item: MTextbook) -> Single<Int> {
        // SQL: INSERT INTO TEXTBOOKS (ID, LANGID, NAME, UNITS, PARTS) VALUES (?,?,?,?,?)
        let url = "\(CommonApi.urlAPI)TEXTBOOKS"
        return RestApi.create(url: url, body: item.toParameters(isSP: false)).map { Int($0)! }.do(onSuccess: { print($0) })
    }
}

class MTextbookEdit {
    let ID: String
    let TEXTBOOKNAME: BehaviorRelay<String>
    let UNITS: BehaviorRelay<String>
    let PARTS: BehaviorRelay<String>

    init(x: MTextbook) {
        ID = "\(x.ID)"
        TEXTBOOKNAME = BehaviorRelay(value: x.TEXTBOOKNAME)
        UNITS = BehaviorRelay(value: x.UNITS)
        PARTS = BehaviorRelay(value: x.PARTS)
    }

    func save(to x: MTextbook) {
        x.TEXTBOOKNAME = TEXTBOOKNAME.value
        x.UNITS = UNITS.value
        x.PARTS = PARTS.value
    }
}
