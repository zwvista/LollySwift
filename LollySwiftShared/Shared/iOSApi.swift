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
    
    static func googleString(_ str: String) {
        UIApplication.shared.openURL(URL(string: "https://www.google.com/search?q=\(str)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
    }
}
