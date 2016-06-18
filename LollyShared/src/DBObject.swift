//
//  DBObject.swift
//  LollyShared
//
//  Created by 趙偉 on 2016/03/20.
//  Copyright © 2016年 趙 偉. All rights reserved.
//
// http://mbehan.com/post/105556974748/super-basic-orm-on-top-of-fmdb-and-sqlite-for-ios

import Foundation

public class DBObject: NSObject {
    
    // http://stackoverflow.com/questions/25575030/how-to-convert-nsnull-to-nil-in-swift
    // http://stackoverflow.com/questions/32360733/null-string-crashes-swift-conditional
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }

    init(databaseResultSet resultSet: FMResultSet) {
        super.init()
        var propertyCount : CUnsignedInt = 0
        let properties = class_copyPropertyList(self.dynamicType, &propertyCount)
        
        for i in 0 ..< Int(propertyCount) {
            let property = properties[i]
            if let propertyName = NSString(CString: property_getName(property), encoding: NSUTF8StringEncoding) as? String {
                self.setValue(nullToNil(resultSet.objectForColumnName(propertyName)), forKey: propertyName)
            }
        }
        free(properties)
    }

}