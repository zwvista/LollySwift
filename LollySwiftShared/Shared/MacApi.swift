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

    static func openURL(_ url: String) {
        NSWorkspace.shared.open(URL(string: url)!)
    }

    static func googleString(_ str: String) {
        openURL("https://www.google.com/search?q=\(str.urlEncoded())")
    }
}

// https://stackoverflow.com/questions/35240607/get-cgcolor-from-hex-string-in-swift-os-x
/**
 * A NSColor extension
 **/
public extension NSColor {

    /**
     Returns an NSColor instance from the given hex value

     - parameter rgbValue: The hex value to be used for the color
     - parameter alpha:    The alpha value of the color

     - returns: A NSColor instance from the given hex value
     */
    class func hexColor(rgbValue: Int, alpha: CGFloat = 1.0) -> NSColor {

        NSColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0, green:((CGFloat)((rgbValue & 0xFF00) >> 8))/255.0, blue:((CGFloat)(rgbValue & 0xFF))/255.0, alpha:alpha)

    }

}

public extension NSControl {
    // https://stackoverflow.com/questions/49797651/nsbutton-list-or-unbind-existing-bindings-programmatically
    func unbindAll() {
        for b in exposedBindings {
            unbind(b)
        }
    }
}
