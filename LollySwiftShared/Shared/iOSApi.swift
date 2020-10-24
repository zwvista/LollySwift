//
//  iOSApi.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2019/02/11.
//  Copyright © 2019 趙 偉. All rights reserved.
//

import UIKit
import AVFoundation

class iOSApi {
    static let synth = AVSpeechSynthesizer()
    static let utterance = AVSpeechUtterance()
    
    static func copyText(_ text: String) {
        UIPasteboard.general.string = text
    }
    
    static func googleString(_ str: String) {
        UIApplication.shared.open(URL(string: "https://www.google.com/search?q=\(str.urlEncoded())")!)
    }
}
