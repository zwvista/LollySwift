//
//  String.swift
//  LollyShared
//
//  Created by 趙偉 on 2016/06/28.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

// http://stackoverflow.com/questions/24091233/swift-split-string-over-multiple-lines
extension String {
    init(sep:String, _ lines:String...){
        self = ""
        for (idx, item) in lines.enumerate() {
            self += "\(item)"
            if idx < lines.count-1 {
                self += sep
            }
        }
    }
    
    init(_ lines:String...){
        self = ""
        for (idx, item) in lines.enumerate() {
            self += "\(item)"
            if idx < lines.count-1 {
                self += "\n"
            }
        }
    }
}
