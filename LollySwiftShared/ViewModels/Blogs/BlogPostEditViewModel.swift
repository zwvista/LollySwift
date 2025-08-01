//
//  BlogPostEditViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/12/22.
//  Copyright © 2018 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxBinding

class BlogPostEditViewModel: NSObject {

    var itemPost: MLangBlogPostContent? = nil
    var isUnitBlog: Bool { itemPost == nil }
    let title: String
    init(item: MLangBlogPostContent?) {
        itemPost = item
        title = item == nil ? vmSettings.BLOGUNITINFO : itemPost!.TITLE
    }

    private static func html1With(_ s: String) -> String {
        "<strong><span style=\"color:#0000ff;?\">\(s)</span></strong>"
    }
    private static func htmlWordWith(_ s: String) -> String { html1With(s + "：") }
    private static func htmlBWith(_ s: String) -> String { html1With(s) }
    // tag for explantion 1
    private static func htmlE1With(_ s: String) -> String {
        "<span style=\"color:#006600;?\">\(s)</span>"
    }
    private static func html2With(_ s: String) -> String {
        "<span style=\"color:#cc00cc;?\">\(s)</span>"
    }
    // tag for explantion 2
    private static func htmlE2With(_ s: String) -> String { html2With(s) }
    private static func htmlIWith(_ s: String) -> String { "<strong>\(html2With(s))</strong>" }
    private static let htmlEmptyLine = "<div><br></div>"
    nonisolated(unsafe) private static let regMarkedEntry = /(\*\*?)\s*(.*?)：(.*?)：(.*)/
    nonisolated(unsafe) private static let regMarkedB = #/<B>(.+?)</B>/#
    nonisolated(unsafe) private static let regMarkedI = #/<I>(.+?)</I>/#
    static func markedToHtml(text: String) -> String {
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
        return CommonApi.toHtml(text: arr.joined(separator: "\n"))
    }

    @MainActor private static let regLine = #/<div>(.*?)</div>/#
    private static var regHtmlB: Regex<(Substring, Substring)> { try! Regex(htmlBWith("(.+?)")) }
    private static var regHtmlI: Regex<(Substring, Substring)> { try! Regex(htmlIWith("(.+?)")) }
    private static var regHtmlEntry: Regex<(Substring, Substring, Substring, Optional<Substring>, Optional<Substring>)> { try!  Regex("(<li>|<br>)\(htmlWordWith("(.*?)"))(?:\(htmlE1With("(.*?)")))?(?:\(htmlE2With("(.*?)")))?(?:</li>)?") }
    @MainActor static func htmlToMarked(text: String) -> String {
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

    static func addTagB(text: String) -> String {
        "<B>\(text)</B>"
    }
    static func addTagI(text: String) -> String {
        "<I>\(text)</I>"
    }
    static func removeTagBI(text: String) -> String {
        text.replacing(#/</?[BI]>/#, with: "")
    }
    static func exchangeTagBI(text: String) -> String {
        var text = text.replacing(#/<(/)?B>/#) { m in "<\(m.1 ?? "")Temp>" }
        text = text.replacing(#/<(/)?I>/#) { m in "<\(m.1 ?? "")B>" }
        text = text.replacing(#/<(/)?Temp>/#) { m in "<\(m.1 ?? "")I>" }
        return text
    }
    static func getExplanation(text: String) -> String {
        "* \(text)：：\n"
    }
    static func getPatternUrl(patternNo: String) -> String {
        "http://viethuong.web.fc2.com/MONDAI/\(patternNo).html"
    }
    
    @MainActor func addNotes(text: String, complete: @escaping (String) -> Void) {
        func f(_ s: String) -> String {
            var t = s
            for i in 0...9 {
                t = t.replacingOccurrences(of: String(i), with: bigDigitsArray[i])
            }
            return t
        }
        var arr = text.components(separatedBy: "\n")
        vmSettings.getNotes(wordCount: arr.count, isNoteEmpty: {
            let m = arr[$0].firstMatch(of: BlogPostEditViewModel.regMarkedEntry)
            if m == nil { return false }
            let word = String(m!.2)
            return word.allSatisfy { $0 != "（" && !bigDigits.contains($0) }
        }, getOne: { [unowned self] i in
            let m = arr[i].firstMatch(of: BlogPostEditViewModel.regMarkedEntry)!
            let (s1, word, s3, s4) = (String(m.1), String(m.2), String(m.3), String(m.4))
            vmSettings.getNote(word: word).subscribe { note in
                let j = note.firstIndex { "0"..."9" ~= $0 }
                // https://stackoverflow.com/questions/45562662/how-can-i-use-string-slicing-subscripts-in-swift-4
                let s21 = j == nil ? note : String(note[..<j!])
                let s22 = j == nil ? "" : f(String(note[j!...]))
                let s2 = word + (s21 == word || s21.isEmpty ? "" : "（\(s21)）") + s22
                arr[i] = "\(s1) \(s2)：\(s3)：\(s4)"
            } ~ rx.disposeBag
        }, allComplete: {
            let result = arr.joined(separator: "\n")
            complete(result)
        }) ~ rx.disposeBag
    }

    func loadBlog(onLoaded: @escaping (String) -> ()) {
        if isUnitBlog {
            vmSettings.getBlogContent().subscribe {
                onLoaded($0)
            } ~ rx.disposeBag
        } else {
            MLangBlogPostContent.getDataById(itemPost!.ID).subscribe {
                onLoaded($0?.CONTENT ?? "")
            } ~ rx.disposeBag
        }
    }

    func saveBlog(content: String) {
        if isUnitBlog {
            vmSettings.saveBlogContent(content: content).subscribe() ~ rx.disposeBag
        } else {
            itemPost!.CONTENT = content
            MLangBlogPostContent.update(item: itemPost!).subscribe() ~ rx.disposeBag
        }
    }
}

let bigDigits = "０１２３４５６７８９"
let bigDigitsArray = bigDigits.map { String($0) }
