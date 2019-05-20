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
class MTextbook: NSObject, Codable {
    var ID = 0
    var LANGID = 0
    var TEXTBOOKNAME = ""
    var UNITS = ""
    var PARTS = ""

    enum CodingKeys : String, CodingKey {
        case ID
        case LANGID
        case TEXTBOOKNAME = "NAME"
        case UNITS
        case PARTS
    }

    var arrUnits = [MSelectItem]()
    var arrParts = [MSelectItem]()
    func UNITSTR(_ unit: Int) -> String {
        return arrUnits.first { $0.value == unit }!.label
    }
    func PARTSTR(_ part: Int) -> String {
        return arrParts.first { $0.value == part }!.label
    }

    override var description: String {
        return TEXTBOOKNAME;
    }

    static func getDataByLang(_ langid: Int) -> Observable<[MTextbook]> {
        // SQL: SELECT * FROM TEXTBOOKS WHERE LANGID=?
        let url = "\(CommonApi.url)TEXTBOOKS?transform=1&filter=LANGID,eq,\(langid)"
        let o: Observable<[MTextbook]> = RestApi.getArray(url: url, keyPath: "TEXTBOOKS")
        func f(units: String) -> [String] {
            if let m = #"UNITS,(\d+)"#.r!.findFirst(in: units) {
                let n = Int(m.group(at: 1)!)!
                return (1...n).map{ String($0) }
            } else if let m = #"PAGES,(\d+),(\d+)"#.r!.findFirst(in: units) {
                let (n1, n2) = (Int(m.group(at: 1)!)!, Int(m.group(at: 2)!)!)
                let n = (n1 + n2 - 1) / n2
                return (1...n).map { "\($0 * n2 - n2 + 1)~\($0 * n2)" }
            } else if let m = "CUSTOM,(.+)".r!.findFirst(in: units) {
                return m.group(at: 1)!.split(",")
            } else {
                return []
            }
        }
        return o.map { arr in
            arr.forEach { row in
                row.arrUnits = f(units: row.UNITS).enumerated().map { MSelectItem(value: $0.0 + 1, label: $0.1) }
                row.arrParts = row.PARTS.split(",").enumerated().map { MSelectItem(value: $0.0 + 1, label: $0.1) }
            }
            return arr
        }
    }

    static func update(item: MTextbook) -> Observable<()> {
        // SQL: UPDATE TEXTBOOKS SET NAME=?, UNITS=?, PARTS=? WHERE ID=?
        let url = "\(CommonApi.url)TEXTBOOKS/\(item.ID)"
        return RestApi.update(url: url, body: try! item.toJSONString(prettyPrint: false)!).map { print($0) }
    }

    static func create(item: MTextbook) -> Observable<()> {
        // SQL: INSERT INTO TEXTBOOKS (ID, LANGID, NAME, UNITS, PARTS) VALUES (?,?,?,?,?)
        let url = "\(CommonApi.url)TEXTBOOKS"
        return RestApi.create(url: url, body: try! item.toJSONString(prettyPrint: false)!).map {
            return $0.toInt()!
        }
    }
}
