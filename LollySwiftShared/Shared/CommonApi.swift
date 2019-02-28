//
//  Common.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2018/11/03.
//  Copyright © 2018 趙 偉. All rights reserved.
//

import Foundation

enum DictWebViewStatus {
    case ready
    case navigating
    case automating
}

class CommonApi {
    static func unitsFrom(info: String) -> [MSelectItem] {
        var arrUnits = [String]()
        if let m = "UNITS,(\\d+)".r!.findFirst(in: info) {
            let units = Int(m.group(at: 1)!)!
            arrUnits = (1...units).map{ String($0) }
        } else if let m = "PAGES,(\\d+),(\\d+)".r!.findFirst(in: info) {
            let (n1, n2) = (Int(m.group(at: 1)!)!, Int(m.group(at: 2)!)!)
            let units = (n1 + n2 - 1) / n2
            arrUnits = (1...units).map { "\($0 * n2 - n2 + 1)~\($0 * n2)" }
        } else if let m = "CUSTOM,(.+)".r!.findFirst(in: info) {
            arrUnits = m.group(at: 1)!.split(",")
        }
        return arrUnits.enumerated().map { MSelectItem(value: $0.0 + 1, label: $0.1) }
    }
    static func partsFrom(parts: String) -> [MSelectItem] {
        return parts.split(",").enumerated().map { MSelectItem(value: $0.0 + 1, label: $0.1) }
    }
}
