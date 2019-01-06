//
//  BlogViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/12/22.
//  Copyright © 2018 趙偉. All rights reserved.
//

import Foundation

class BlogViewModel: NSObject {

    public func markedToHtml(text: String) -> String {
        var arr = text.components(separatedBy: "\n")
        let reg = "(\\*\\*?)\\s*(.*?)：(.*?)：(.*)".r!
        var i = 0
        while i < arr.count {
            var s = arr[i]
            if let m = reg.findFirst(in: s) {
                let (s1, s2, s3, s4) = (m.group(at: 1)!, m.group(at: 2)!, m.group(at: 3)!, m.group(at: 4))
                s = "<strong><span style=\"color:#0000ff;\">\(s2)：</span></strong>" +
                    (s3.isEmpty ? "" : "<span style=\"color:#006600;\">\(s3)</span>") +
                    ((s4 ?? "").isEmpty ? "" : "<span style=\"color:#cc00cc;\">\(s4!)</span>")
                arr[i] = s1 == "*" ? "<li>\(s)</li>" : "<br>" + s
                if (i == 0 || arr[i - 1].hasPrefix("<div>")) {
                    arr.insert("<ul>", at: i)
                    i += 1
                }
                if i == arr.count - 1 || !reg.matches(arr[i + 1]) {
                    arr.insert("</ul>", at: i + 1)
                    i += 1
                }
            } else if s.isEmpty {
                arr[i] = "<div><br></div>"
            } else {
                s = "<B>(.+?)</B>".r!.replaceAll(in: s, with: "<strong><span style=\"color:#0000ff;\">$1</span></strong>")
                s = "<I>(.+?)</I>".r!.replaceAll(in: s, with: "<strong><span style=\"color:#cc00cc;\">$1</span></strong>")
                arr[i] = "<div>\(s)</div>"
            }
            i += 1
        }
        return arr.joined(separator: "\n")
    }
    
    public func htmlToMarked(text: String) -> String {
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
                s = "<strong><span style=\"color:#0000ff;\">(.+?)</span></strong>".r!.replaceAll(in: s, with: "<B>$1</B>")
                s = "<strong><span style=\"color:#cc00cc;\">(.+?)</span></strong>".r!.replaceAll(in: s, with: "<I>$1</I>")
                arr[i] = s
            } else if let m = "<li><strong><span style=\"color:#0000ff;\">(.*?)：</span></strong>(?:<span style=\"color:#006600;\">(.*?)</span>)?(?:<span style=\"color:#cc00cc;\">(.*?)</span>)?</li>".r!.findFirst(in: s) {
                let (s1, s2, s3) = (m.group(at: 1), m.group(at: 2), m.group(at: 3))
                s = "* \(s1 ?? "")：\(s2 ?? "")：\(s3 ?? "")"
                arr[i] = s
            }
            i += 1
        }
        return arr.joined(separator: "\n")
    }
    
    public func addTagB(text: String) -> String {
        return "<B>\(text)</B>"
    }
    public func addTagI(text: String) -> String {
        return "<I>\(text)</I>"
    }
    public func removeTags(text: String) -> String {
        return "</?[BI]>".r!.replaceAll(in: text, with: "")
    }
    public let explanation = "* ：：\n"
    public func getHtml(text: String) -> String {
        return "<html><body>\(text)</body></html>"
    }
    public func getPatternUrl(patternNo: String) -> String {
        return "http://viethuong.web.fc2.com/MONDAI/\(patternNo).html"
    }
    public func getPatternMarkDown(patternText: String) -> String {
        return "* [\(patternText)　文法](https://www.google.com/search?q=\(patternText)　文法)\n* [\(patternText)　句型](https://www.google.com/search?q=\(patternText)　句型)"
    }
}
