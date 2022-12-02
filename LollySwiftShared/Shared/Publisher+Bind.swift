//
//  Publisher+Bind.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2022/12/02.
//  Copyright © 2022 趙偉. All rights reserved.
//

import Foundation
import Combine

extension Publisher where Self.Failure == Never {
    public static func ~> (pub1: Self, pub2: inout Published<Self.Output>.Publisher) {
        pub1.assign(to: &pub2)
    }
}
