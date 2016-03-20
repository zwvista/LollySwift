//
//  DBObject.swift
//  LollyShared
//
//  Created by 趙偉 on 2016/03/20.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import Foundation

public class DBObject: NSObject {
    
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
        
        for var i = 0; i < Int(propertyCount); ++i {
            let property = properties[i]
            if let propertyName = NSString(CString: property_getName(property), encoding: NSUTF8StringEncoding) as? String {
                self.setValue(nullToNil(resultSet.objectForColumnName(propertyName)), forKey: propertyName)
            }
        }
        free(properties)
    }

}
