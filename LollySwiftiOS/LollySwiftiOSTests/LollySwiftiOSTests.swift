//
//  LollySwiftiOSTests.swift
//  LollySwiftiOSTests
//
//  Created by zhaowei on 2014/11/08.
//  Copyright (c) 2014年 趙 偉. All rights reserved.
//

import UIKit
import XCTest

class LollySwiftiOSTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let vm = SettingsViewModel()
        vm.getData().subscribe {
            XCTAssertEqual(vm.arrLanguages.count, 10)
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
