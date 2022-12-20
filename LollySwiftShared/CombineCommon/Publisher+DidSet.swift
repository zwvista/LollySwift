//
//  Publisher+DidSet.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2022/12/21.
//  Copyright © 2022 趙 偉. All rights reserved.
//

import Foundation
import Combine

// https://stackoverflow.com/questions/58403338/is-there-an-alternative-to-combines-published-that-signals-a-value-change-afte
extension Published.Publisher {
    var didSet: AnyPublisher<Value, Never> {
        self.receive(on: RunLoop.main).eraseToAnyPublisher()
    }
}
