//
//  Common.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2018/11/03.
//  Copyright © 2018 趙 偉. All rights reserved.
//

import Foundation
import Regex

enum DictWebViewStatus {
    case ready
    case navigating
    case automating
}

enum ReviewMode: Int {
    case reviewAuto
    case test
    case reviewManual
}

enum UnitPartToType: Int {
    case unit
    case part
    case to
}

class CommonApi {
    
    static public let userid = 1
    static let urlAPI = "https://zwvista.tk/lolly/api.php/records/"
    static let urlSP = "https://zwvista.tk/lolly/sp.php/"
    static let cssFolder = "https://zwvista.tk/lolly/css/"
    
    static func removeReturns(html: String) -> String {
        html.replacingOccurrences(of: "\r\n", with: "\n")
    }
    
    static func toTransformItems(transform: String) -> [MTransformItem] {
        var arr = transform.components(separatedBy: "\r\n")
        if arr.count % 2 == 1 { arr.removeLast() }
        let dic = Dictionary(grouping: arr.enumerated(), by: { $0.0 / 2 })
        let items: [MTransformItem] = dic.map { i, a in
            let o = MTransformItem()
            o.index = i + 1
            o.extractor = a[0].element
            o.replacement = a[1].element
            return o
        }.sorted { $0.index < $1.index }
        return items
    }
    
    static func doTransform(text: String, item: MTransformItem) -> String {
        let dic = ["<delete>": "", "\\t": "\t", "\\n": "\n"]
        var s = text
        let regex = item.extractor.r!
        var replacement = item.replacement
        if replacement.starts(with: "<extract>") {
            replacement = String(replacement.dropFirst("<extract>".length))
            let ms = regex.findAll(in: s)
            s = ms.reduce("", { (acc, m) in acc + m.matched })
            if s.isEmpty { return s }
        }
        for (key, value) in dic {
            replacement = replacement.replacingOccurrences(of: key, with: value)
        }
        s = regex.replaceAll(in: s, with: replacement)
        return s
    }
    
    static func extractText(from html: String, transform: String, template: String, templateHandler: (String, String) -> String) -> String {
        // NSRegularExpression cannot handle "\r"
        var text = removeReturns(html: html)
        repeat {
            if transform.isEmpty {break}
            let arr = toTransformItems(transform: transform)
            for item in arr {
                text = doTransform(text: text, item: item)
            }
            if template.isEmpty {break}
            text = templateHandler(text, template)
        } while false
        return text
    }
    
    static func getAccuracy(CORRECT: Int, TOTAL: Int) -> String {
        TOTAL == 0 ? "N/A" : "\(floor(CORRECT.toDouble / TOTAL.toDouble * 1000) / 10)%"
    }
}
