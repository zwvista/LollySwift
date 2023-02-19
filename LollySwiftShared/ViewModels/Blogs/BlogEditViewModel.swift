//
//  BlogEditViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/12/22.
//  Copyright © 2018 趙偉. All rights reserved.
//

import Foundation

@MainActor
class BlogEditViewModel: NSObject {

    var isUnitBlog: Bool
    var vmSettings: SettingsViewModel
    var itemBlog: MLangBlogContent? = nil
    init(settings: SettingsViewModel, item: MLangBlogContent?) {
        vmSettings = SettingsViewModel(settings)
        itemBlog = item
        isUnitBlog = item == nil
    }

    private func html1With(_ s: String) -> String {
        "<strong><span style=\"color:#0000ff\">\(s)</span></strong>"
    }
    private func htmlWordWith(_ s: String) -> String { html1With(s + "：") }
    private func htmlBWith(_ s: String) -> String { html1With(s) }
    // tag for explantion 1
    private func htmlE1With(_ s: String) -> String {
        "<span style=\"color:#006600\">\(s)</span>"
    }
    private func html2With(_ s: String) -> String {
        "<span style=\"color:#cc00cc\">\(s)</span>"
    }
    // tag for explantion 2
    private func htmlE2With(_ s: String) -> String { html2With(s) }
    private func htmlIWith(_ s: String) -> String { "<strong>\(html2With(s))</strong>" }
    private let htmlEmptyLine = "<div><br></div>"
    private let regMarkedEntry = /(\*\*?)\s*(.*?)：(.*?)：(.*)/
    private let regMarkedB = #/<B>(.+?)</B>/#
    private let regMarkedI = #/<I>(.+?)</I>/#
    func markedToHtml(text: String) -> String {
        var arr = text.components(separatedBy: "\n")
        var i = 0
        while i < arr.count {
            var s = arr[i]
            if let m = s.firstMatch(of: regMarkedEntry) {
                let (s1, s2, s3, s4) = (String(m.1), String(m.2), String(m.3), String(m.4))
                s = htmlWordWith(s2) + (s3.isEmpty ? "" : htmlE1With(s3)) + (s4.isEmpty ? "" : htmlE2With(s4))
                arr[i] = (s1 == "*" ? "<li>" : "<br>") + s
                if i == 0 || arr[i - 1].hasPrefix("<div>") {
                    arr.insert("<ul>", at: i)
                    i += 1
                }
                let isLast = i == arr.count - 1
                let m2 = isLast ? nil : arr[i + 1].firstMatch(of: regMarkedEntry)
                if isLast || m2?.1 != "**" {
                    arr[i] += "</li>"
                }
                if isLast || m2 == nil {
                    arr.insert("</ul>", at: i + 1)
                    i += 1
                }
            } else if s.isEmpty {
                arr[i] = htmlEmptyLine
            } else {
                s = s.replacing(regMarkedB) { m in htmlBWith(String(m.1)) }
                s = s.replacing(regMarkedI) { m in htmlIWith(String(m.1)) }
                arr[i] = "<div>\(s)</div>"
            }
            i += 1
        }
        return arr.joined(separator: "\n")
    }

    private let regLine = #/<div>(.*?)</div>/#
    private var regHtmlB: Regex<(Substring, Substring)> { try! Regex(htmlBWith("(.+?)")) }
    private var regHtmlI: Regex<(Substring, Substring)> { try! Regex(htmlIWith("(.+?)")) }
    private var regHtmlEntry: Regex<(Substring, Substring, Substring, Optional<Substring>, Optional<Substring>)> { try!  Regex("(<li>|<br>)\(htmlWordWith("(.*?)"))(?:\(htmlE1With("(.*?)")))?(?:\(htmlE2With("(.*?)")))?(?:</li>)?") }
    func htmlToMarked(text: String) -> String {
        var arr = text.split(separator: "\n").map { String($0) }
        var i = 0
        while i < arr.count {
            var s = arr[i]
            if s == "<!-- wp:html -->" || s == "<!-- /wp:html -->" || s == "<ul>" || s == "</ul>" {
                arr.remove(at: i)
                i -= 1
            } else if s == htmlEmptyLine {
                arr[i] = ""
            } else if let m = s.firstMatch(of: regLine) {
                s = String(m.1)
                s = s.replacing(regHtmlB) { m in "<B>\(m.1)</B>" }
                s = s.replacing(regHtmlI) { m in "<I>\(m.1)</I>" }
                arr[i] = s
            } else if let m = s.firstMatch(of: regHtmlEntry) {
                let (s1, s2, s3, s4) = (String(m.1), String(m.2), String(m.3 ?? ""), String(m.4 ?? ""))
                s = (s1 == "<li>" ? "*" : "**") + " \(s2)：\(s3)：\(s4)"
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
        text.replacing(#/</?[BI]>/#, with: "")
    }
    func exchangeTagBI(text: String) -> String {
        var text = text.replacing(#/<(/)?B>/#) { m in "<\(m.1 ?? "")Temp>" }
        text = text.replacing(#/<(/)?I>/#) { m in "<\(m.1 ?? "")B>" }
        text = text.replacing(#/<(/)?Temp>/#) { m in "<\(m.1 ?? "")I>" }
        return text
    }
    func getExplanation(text: String) -> String {
        "* \(text)：：\n"
    }
    func getPatternUrl(patternNo: String) -> String {
        "http://viethuong.web.fc2.com/MONDAI/\(patternNo).html"
    }

    func addNotes(text: String, complete: @escaping (String) -> Void) async {
        func f(_ s: String) -> String {
            var t = s
            for i in 0...9 {
                t = t.replacingOccurrences(of: String(i), with: bigDigitsArray[i])
            }
            return t
        }
        var arr = text.components(separatedBy: "\n")
        await vmSettings.getNotes(wordCount: arr.count, isNoteEmpty: { [unowned self] in
            let m = arr[$0].firstMatch(of: regMarkedEntry)
            if m == nil { return false }
            let word = String(m!.2)
            return word.allSatisfy { $0 != "（" && !bigDigits.contains($0) }
        }, getOne: { [unowned self] i in
            let m = arr[i].firstMatch(of: regMarkedEntry)!
            let (s1, word, s3, s4) = (String(m.1), String(m.2), String(m.3), String(m.4))
            let note = await vmSettings.getNote(word: word)
            let j = note.firstIndex { "0"..."9" ~= $0 }
            // https://stackoverflow.com/questions/45562662/how-can-i-use-string-slicing-subscripts-in-swift-4
            let s21 = j == nil ? note : String(note[..<j!])
            let s22 = j == nil ? "" : f(String(note[j!...]))
            let s2 = word + (s21 == word || s21.isEmpty ? "" : "（\(s21)）") + s22
            arr[i] = "\(s1) \(s2)：\(s3)：\(s4)"
        }, allComplete: {
            let result = arr.joined(separator: "\n")
            complete(result)
        })
    }
}

let bigDigits = "０１２３４５６７８９"
let bigDigitsArray = bigDigits.map { String($0) }
