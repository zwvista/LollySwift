//
//  BlogViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/12/22.
//  Copyright © 2018 趙偉. All rights reserved.
//

import Foundation
import Regex
import RxSwift

class BlogViewModel: NSObject {
    
    var vmSettings: SettingsViewModel
    init(settings: SettingsViewModel) {
        self.vmSettings = SettingsViewModel(settings)
    }
    
    private func html1With(_ s: String) -> String {
        "<strong><span style=\"color:#0000ff;\">\(s)</span></strong>"
    }
    private func htmlWordWith(_ s: String) -> String { html1With(s + "：") }
    private func htmlBWith(_ s: String) -> String { html1With(s) }
    // tag for explantion 1
    private func htmlE1With(_ s: String) -> String {
        "<span style=\"color:#006600;\">\(s)</span>"
    }
    private func html2With(_ s: String) -> String {
        "<span style=\"color:#cc00cc;\">\(s)</span>"
    }
    // tag for explantion 2
    private func htmlE2With(_ s: String) -> String { html2With(s) }
    private func htmlIWith(_ s: String) -> String { "<strong>\(html2With(s))</strong>" }
    private let htmlEmptyLine = "<div><br></div>"
    private let regMarkedEntry = #"(\*\*?)\s*(.*?)：(.*?)：(.*)"#.r!
    private let regMarkedB = "<B>(.+?)</B>".r!
    private let regMarkedI = "<I>(.+?)</I>".r!
    func markedToHtml(text: String) -> String {
        var arr = text.components(separatedBy: "\n")
        var i = 0
        while i < arr.count {
            var s = arr[i]
            if let m = regMarkedEntry.findFirst(in: s) {
                let (s1, s2, s3, s4) = (m.group(at: 1)!, m.group(at: 2)!, m.group(at: 3)!, m.group(at: 4))
                s = htmlWordWith(s2) + (s3.isEmpty ? "" : htmlE1With(s3)) + ((s4 ?? "").isEmpty ? "" : htmlE2With(s4!))
                arr[i] = (s1 == "*" ? "<li>" : "<br>") + s
                if i == 0 || arr[i - 1].hasPrefix("<div>") {
                    arr.insert("<ul>", at: i)
                    i += 1
                }
                let isLast = i == arr.count - 1
                let m2 = isLast ? nil : regMarkedEntry.findFirst(in: arr[i + 1])
                if isLast || m2?.group(at: 1) != "**" {
                    arr[i] += "</li>"
                }
                if isLast || m2 == nil {
                    arr.insert("</ul>", at: i + 1)
                    i += 1
                }
            } else if s.isEmpty {
                arr[i] = htmlEmptyLine
            } else {
                s = regMarkedB.replaceAll(in: s, with: htmlBWith("$1"))
                s = regMarkedI.replaceAll(in: s, with: htmlIWith("$1"))
                arr[i] = "<div>\(s)</div>"
            }
            i += 1
        }
        return arr.joined(separator: "\n")
    }
    
    private let regLine = "<div>(.*?)</div>".r!
    private var regHtmlB: Regex { htmlBWith("(.+?)").r! }
    private var regHtmlI: Regex { htmlIWith("(.+?)").r! }
    private var regHtmlEntry: Regex {  "(<li>|<br>)\(htmlWordWith("(.*?)"))(?:\(htmlE1With("(.*?)")))?(?:\(htmlE2With("(.*?)")))?(?:</li>)?".r! }
    func htmlToMarked(text: String) -> String {
        var arr = text.split("\n")
        var i = 0
        while i < arr.count {
            var s = arr[i]
            if s == "<!-- wp:html -->" || s == "<!-- /wp:html -->" || s == "<ul>" || s == "</ul>" {
                arr.remove(at: i)
                i -= 1
            } else if s == htmlEmptyLine {
                arr[i] = ""
            } else if let m = regLine.findFirst(in: s) {
                s = m.group(at: 1)!
                s = regHtmlB.replaceAll(in: s, with: "<B>$1</B>")
                s = regHtmlI.replaceAll(in: s, with: "<I>$1</I>")
                arr[i] = s
            } else if let m = regHtmlEntry.findFirst(in: s) {
                let (s1, s2, s3, s4) = (m.group(at: 1), m.group(at: 2), m.group(at: 3), m.group(at: 4))
                s = (s1 == "<li>" ? "*" : "**") + " \(s2 ?? "")：\(s3 ?? "")：\(s4 ?? "")"
                arr[i] = s
            }
            i += 1
        }
        return arr.joined(separator: "\n")
    }
    
    func addTagB(text: String) -> String {
        "<B>\(text)</B>"
    }
    func addTagI(text: String) -> String {
        "<I>\(text)</I>"
    }
    func removeTagBI(text: String) -> String {
        "</?[BI]>".r!.replaceAll(in: text, with: "")
    }
    func exchangeTagBI(text: String) -> String {
        var text = "<(/)?B>".r!.replaceAll(in: text, with: "<$1Temp>")
        text = "<(/)?I>".r!.replaceAll(in: text, with: "<$1B>")
        text = "<(/)?Temp>".r!.replaceAll(in: text, with: "<$1I>")
        return text
    }
    func getExplanation(text: String) -> String {
        "* \(text)：：\n"
    }
    func getPatternUrl(patternNo: String) -> String {
        "http://viethuong.web.fc2.com/MONDAI/\(patternNo).html"
    }
    func getPatternMarkDown(patternText: String) -> String {
        "* [\(patternText)　文法](https://www.google.com/search?q=\(patternText)　文法)\n* [\(patternText)　句型](https://www.google.com/search?q=\(patternText)　句型)"
    }
    
    private let bigDigits = "０１２３４５６７８９"
    func addNotes(text: String, complete: @escaping (String) -> Void) {
        func f(_ s: String) -> String {
            var t = s
            for i in 0...9 {
                t = t.replacingOccurrences(of: String(i), with: bigDigits[i...i])
            }
            return t
        }
        var arr = text.components(separatedBy: "\n")
        vmSettings.getNotes(wordCount: arr.count, isNoteEmpty: {
            let m = self.regMarkedEntry.findFirst(in: arr[$0])
            if m == nil { return false }
            let word = m!.group(at: 2)!
            return word.allSatisfy { $0 != "（" && !self.bigDigits.contains($0) }
        }, getOne: { i in
            let m = self.regMarkedEntry.findFirst(in: arr[i])!
            let (s1, word, s3, s4) = (m.group(at: 1)!, m.group(at: 2)!, m.group(at: 3)!, m.group(at: 4))
            self.vmSettings.getNote(word: word).subscribe(onNext: { note in
                let j = note.firstIndex { "0"..."9" ~= $0 }
                // https://stackoverflow.com/questions/45562662/how-can-i-use-string-slicing-subscripts-in-swift-4
                let s21 = j == nil ? note : String(note[..<j!])
                let s22 = j == nil ? "" : f(String(note[j!...]))
                let s2 = word + (s21 == word || s21.isEmpty ? "" : "（\(s21)）") + s22
                arr[i] = "\(s1) \(s2)：\(s3)：\(s4 ?? "")"
            }) ~ self.rx.disposeBag
        }, allComplete: {
            let result = arr.joined(separator: "\n")
            complete(result)
        })
    }
}
