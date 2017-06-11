//
//  DBObject.swift
//  LollySwiftShared
//
//  Created by 趙偉 on 2016/03/20.
//  Copyright © 2016年 趙 偉. All rights reserved.
//
// http://mbehan.com/post/105556974748/super-basic-orm-on-top-of-fmdb-and-sqlite-for-ios

import Foundation
open class DBObject: NSObject {
    
    // http://stackoverflow.com/questions/25575030/how-to-convert-nsnull-to-nil-in-swift
    // http://stackoverflow.com/questions/32360733/null-string-crashes-swift-conditional
    func nullToNil(_ value: AnyObject?) -> AnyObject? {
        return value is NSNull ? nil : value;
    }
    
    public override init() {
        super.init()
    }

    required public init(databaseResultSet resultSet: FMResultSet) {
        super.init()
        var propertyCount: CUnsignedInt = 0
        let properties = class_copyPropertyList(type(of: self), &propertyCount)
        let dic = resultSet.columnNameToIndexMap;
        
        for i in 0 ..< Int(propertyCount) {
            let property = properties?[i]
            if let propertyName = NSString(cString: property_getName(property), encoding: String.Encoding.utf8.rawValue) as String? {
                if (dic.object(forKey: propertyName.lowercased()) == nil) {continue}
                self.setValue(nullToNil(resultSet.object(forColumn: propertyName) as AnyObject?), forKey: propertyName)
            }
        }
        free(properties)
    }
    
    static func dataFromResultSet<T: DBObject>(databaseResultSet resultSet: FMResultSet) -> [T] {
        var array = [T]()
        while resultSet.next() {
            let m = T(databaseResultSet: resultSet)
            array.append(m)
        }
        return array
    }
    
    static let dbCore = LollyDB.sharedInstance.dbCore
    static let dbDic = LollyDB.sharedInstance.dbDic
}
