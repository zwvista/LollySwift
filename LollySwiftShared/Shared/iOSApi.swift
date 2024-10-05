//
//  iOSApi.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2019/02/11.
//  Copyright © 2019 趙 偉. All rights reserved.
//

import UIKit

class iOSApi {
    static func copyText(_ text: String) {
        UIPasteboard.general.string = text
    }

    @MainActor static func googleString(_ str: String) {
        UIApplication.shared.open(URL(string: "https://www.google.com/search?q=\(str.urlEncoded())")!)
    }
}
