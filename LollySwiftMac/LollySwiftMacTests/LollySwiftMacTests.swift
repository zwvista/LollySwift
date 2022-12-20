//
//  LollySwiftMacTests.swift
//  LollySwiftMacTests
//
//  Created by 趙偉 on 2016/07/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import XCTest
@testable import LollySwiftMac

class LollySwiftMacTests: XCTestCase {

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
            XCTAssertEqual(vm.arrLanguages.count, 11)
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
