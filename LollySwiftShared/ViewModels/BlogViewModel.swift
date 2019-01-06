//
//  BlogViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/12/22.
//  Copyright © 2018 趙偉. All rights reserved.
//

import Foundation
import Regex

class BlogViewModel: NSObject {
    private func html1With(_ s: String) -> String {
        return "<strong><span style=\"color:#0000ff;\">\(s)</span></strong>"
    }
    private func htmlWordWith(_ s: String) -> String { return html1With(s + "：") }
    private func htmlBWith(_ s: String) -> String { return html1With(s) }
    // tag for explantion 1
    private func htmlE1With(_ s: String) -> String {
        return "<span style=\"color:#006600;\">\(s)</span>"
    }
    private func html2With(_ s: String) -> String {
        return "<span style=\"color:#cc00cc;\">\(s)</span>"
    }
    // tag for explantion 2
    private func htmlE2With(_ s: String) -> String { return html2With(s) }
    private func htmlIWith(_ s: String) -> String { return "<strong>\(html2With(s))</strong>" }
    private let regMarkedEntry = "(\\*\\*?)\\s*(.*?)：(.*?)：(.*)".r!
    private let regMarkedB = "<B>(.+?)</B>".r!
    private let regMarkedI = "<I>(.+?)</I>".r!
    private var regHtmlB: Regex { return htmlBWith("(.+?)").r! }
    private var regHtmlI: Regex { return htmlIWith("(.+?)").r! }
    private var htmlEntry: String { return "\(htmlWordWith("(.*?)"))(?:\(htmlE1With("(.*?)")))?(?:\(htmlE2With("(.*?)")))?" }
    private var regHtmlEntry1: Regex { return "<li>\(htmlEntry)</li>".r! }
    private var regHtmlEntry2: Regex { return "<br>\(htmlEntry)".r! }

    func markedToHtml(text: String) -> String {
        var arr = text.components(separatedBy: "\n")
        var i = 0
        while i < arr.count {
            var s = arr[i]
            if let m = regMarkedEntry.findFirst(in: s) {
                let (s1, s2, s3, s4) = (m.group(at: 1)!, m.group(at: 2)!, m.group(at: 3)!, m.group(at: 4))
                s = htmlWordWith(s2) + (s3.isEmpty ? "" : htmlE1With(s3)) + ((s4 ?? "").isEmpty ? "" : htmlE2With(s4!))
                arr[i] = s1 == "*" ? "<li>\(s)</li>" : "<br>" + s
                if (i == 0 || arr[i - 1].hasPrefix("<div>")) {
                    arr.insert("<ul>", at: i)
                    i += 1
                }
                if i == arr.count - 1 || !regMarkedEntry.matches(arr[i + 1]) {
                    arr.insert("</ul>", at: i + 1)
                    i += 1
                }
            } else if s.isEmpty {
                arr[i] = "<div><br></div>"
            } else {
                s = regMarkedB.replaceAll(in: s, with: htmlBWith("$1"))
                s = regMarkedI.replaceAll(in: s, with: htmlIWith("$1"))
                arr[i] = "<div>\(s)</div>"
            }
            i += 1
        }
        return arr.joined(separator: "\n")
    }
    
    func htmlToMarked(text: String) -> String {
        var arr = text.split("\n")
        var i = 0
        while i < arr.count {
            var s = arr[i]
            if s == "<ul>" || s == "</ul>" {
                arr.remove(at: i)
                i -= 1
            } else if s == "<div><br></div>" {
                arr[i] = ""
            } else if let m = "<div>(.*?)</div>".r!.findFirst(in: s) {
                s = m.group(at: 1)!
                s = regHtmlB.replaceAll(in: s, with: "<B>$1</B>")
                s = regHtmlI.replaceAll(in: s, with: "<I>$1</I>")
                arr[i] = s
            } else if let m = regHtmlEntry1.findFirst(in: s) {
                let (s1, s2, s3) = (m.group(at: 1), m.group(at: 2), m.group(at: 3))
                s = "* \(s1 ?? "")：\(s2 ?? "")：\(s3 ?? "")"
                arr[i] = s
            } else if let m = regHtmlEntry2.findFirst(in: s) {
                let (s1, s2, s3) = (m.group(at: 1), m.group(at: 2), m.group(at: 3))
                s = "** \(s1 ?? "")：\(s2 ?? "")：\(s3 ?? "")"
                arr[i] = s
            }
            i += 1
        }
        return arr.joined(separator: "\n")
    }
    
    func addTagB(text: String) -> String {
        return "<B>\(text)</B>"
    }
    func addTagI(text: String) -> String {
        return "<I>\(text)</I>"
    }
    func removeTags(text: String) -> String {
        return "</?[BI]>".r!.replaceAll(in: text, with: "")
    }
    let explanation = "* ：：\n"
    func getHtml(text: String) -> String {
        return "<html><body>\(text)</body></html>"
    }
    func getPatternUrl(patternNo: String) -> String {
        return "http://viethuong.web.fc2.com/MONDAI/\(patternNo).html"
    }
    func getPatternMarkDown(patternText: String) -> String {
        return "* [\(patternText)　文法](https://www.google.com/search?q=\(patternText)　文法)\n* [\(patternText)　句型](https://www.google.com/search?q=\(patternText)　句型)"
    }
    
//    func getNotes(text: String) -> String {
//
//    }
}
