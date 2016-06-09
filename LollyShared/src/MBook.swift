//
//  MBook.swift
//  LollyShared
//
//  Created by 趙偉 on 2016/06/09.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

class MBook: DBObject {
    public var BOOKID = 0
    public var LANGID = 0
    public var BOOKNAME: String?
    public var UNITSINBOOK = 0
    public var PARTS: String?
    public var UNITFROM = 0
    public var PARTFROM = 0
    public var UNITTO = 0
    public var PARTTO = 0
}
