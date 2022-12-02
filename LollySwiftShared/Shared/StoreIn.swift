//
//  StoreIn.swift
//  CombineBind
//
//  Created by 趙偉 on 2022/12/01.
//

import Foundation
import Combine

precedencegroup DisposePrecedence {
    associativity: left
    
    lowerThan: DefaultPrecedence
}

infix operator ~ : DisposePrecedence

extension AnyCancellable {
    
    public static func ~ (anyCancellable: AnyCancellable, subscriptions: inout Set<AnyCancellable>) {
        anyCancellable.store(in: &subscriptions)
    }
}
