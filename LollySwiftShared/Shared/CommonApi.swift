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

enum ReviewMode: Int {
    case reviewAuto
    case reviewManual
    case test
    case textbook
}

enum UnitPartToType: Int {
    case unit
    case part
    case to
}

class GlobalUser {
    var userid = ""
    var username = ""
}
let globalUser = GlobalUser()

class CommonApi {

    static let urlAPI = "https://zwvista.com/lolly/api.php/records/"
    static let urlSP = "https://zwvista.com/lolly/sp.php/"
    static let cssFolder = "https://zwvista.com/lolly/css/"

    static func removeReturns(html: String) -> String {
        html.replacingOccurrences(of: "\r\n", with: "\n")
    }

    static func toTransformItems(transform: String) -> [MTransformItem] {
        var arr = transform.components(separatedBy: "\r\n")
        if arr.count % 2 == 1 { arr.removeLast() }
        let dic = Dictionary(grouping: arr.enumerated()) { $0.0 / 2 }
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
        let regex = try! Regex(item.extractor)
        var replacement = item.replacement
        if replacement.starts(with: "<extract>") {
            replacement = String(replacement.dropFirst("<extract>".count))
            let ms = s.matches(of: regex)
            var i = 1
            s = ms.reduce("", { (acc, m) in
                let s2 = m.0
                print("[TRANSFORM\(i)]\(s2)[/TRANSFORM\(i)]")
                i += 1
                return acc + s2
            })
            if s.isEmpty { return s }
        }
        for (key, value) in dic {
            replacement = replacement.replacingOccurrences(of: key, with: value)
        }
        s = s.replacing(regex, with: replacementToFunc(replacement))
        return s
    }

    static func replacementToFunc(_ replacement: String) -> (Regex<AnyRegexOutput>.Match) -> String {
        { m in
            var s = replacement
            for i in 1..<10 {
                if s.contains("$\(i)") {
                    s = s.replacing("$\(i)", with: m[i].substring ?? "")
                }
            }
            return s
        }
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
        TOTAL == 0 ? "N/A" : "\(floor(Double(CORRECT) / Double(TOTAL) * 1000) / 10)%"
    }

    static func toHtml(text: String) -> String {
        "<html><body>\(text)</body></html>"
    }

    static func applyTemplate(template: String, word: String, text: String) -> String {
        template.replacingOccurrences(of: "{0}", with: word)
        .replacingOccurrences(of: "{1}", with: CommonApi.cssFolder)
        .replacingOccurrences(of: "{2}", with: text)
    }
}

// https://stackoverflow.com/questions/780897/how-do-i-find-all-the-property-keys-of-a-kvc-compliant-objective-c-object
extension Encodable {
     public func toDictionary() -> [String: AnyObject]? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data =  try? encoder.encode(self),
              let json = try? JSONSerialization.jsonObject(with: data, options: .init(rawValue: 0)), let jsonDict = json as? [String: AnyObject] else {
            return nil
        }
        return jsonDict
    }
}

func copyProperties<T: Encodable & NSObject>(from a: T, to b: T) {
    let keys = a.toDictionary()!.keys
    for k in keys {
        let v = String(describing: a.value(forKey: k) ?? "")
        b.setValue(v, forKey: k)
    }
}

extension Array where Element == String {
    public func splitUsingCommaAndMerge() -> String {
        flatMap { $0.components(separatedBy: ",") }.filter { !$0.isEmpty }.unique.sorted().joined(separator: ",")
    }
}

extension Array {
    public mutating func moveElement(at oldIndex: Int, to newIndex: Int) {
        let item = remove(at: oldIndex)
        insert(item, at: newIndex)
    }
}

// https://stackoverflow.com/questions/27624331/unique-values-of-array-in-swift
extension Array where Element : Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        return uniqueValues
    }
}

extension String {
    public func urlEncoded() -> String {
        self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    public func defaultIfEmpty(_ s: String) -> String {
        self.isEmpty ? s : self
    }
}

extension NSObject {
    public var className: String {
        return String(describing: type(of: self))
    }
}
