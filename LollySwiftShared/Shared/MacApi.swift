//
//  MacApi.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2017/06/24.
//  Copyright © 2017年 趙 偉. All rights reserved.
//

import Cocoa

class MacApi {
    static func copyText(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(text, forType: .string)
    }
}