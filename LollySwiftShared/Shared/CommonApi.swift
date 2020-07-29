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
    
    static func extractText(from html: String, transform: String, template: String, templateHandler: (String, String) -> String) -> String {
        let dic = ["<delete>": "", "\\t": "\t", "\\n": "\n"]
        
        // NSRegularExpression cannot handle "\r"
        var text = html.replacingOccurrences(of: "\r\n", with: "\n")
        print(transform)
        
        repeat {
            if transform.isEmpty {break}
            var arr = transform.components(separatedBy: "\r\n")
            if arr.count % 2 == 1 { arr.removeLast() }

            var i = 0
            while i < arr.count {
                let regex = arr[i].r!
                var replacer = arr[i + 1]
                if replacer.starts(with: "<extract>") {
                    replacer = String(replacer.dropFirst("<extract>".length))
                    let ms = regex.findAll(in: text)
                    text = ms.reduce("", { (acc, m) in acc + m.matched })
                    if text.isEmpty {break}
                }
                for (key, value) in dic {
                    replacer = replacer.replacingOccurrences(of: key, with: value)
                }
                text = regex.replaceAll(in: text, with: replacer)
                i += 2
            }
            
            if template.isEmpty {break}
            text = templateHandler(text, template)
            
        } while false
        
        print(text)
        
        return text
    }
    
    static func getAccuracy(CORRECT: Int, TOTAL: Int) -> String {
        TOTAL == 0 ? "N/A" : "\(floor(CORRECT.toDouble / TOTAL.toDouble * 1000) / 10)%"
    }
}
