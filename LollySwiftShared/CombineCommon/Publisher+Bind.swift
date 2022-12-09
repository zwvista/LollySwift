//
//  Publisher+Bind.swift
//  CombineCommon
//
//  Created by 趙偉 on 2022/12/01.
//

import Foundation
import Combine

infix operator ~> : DefaultPrecedence

func ~><Value> (pub1: Published<Value>.Publisher, pub2: inout Published<Value>.Publisher) {
    pub1.assign(to: &pub2)
}
func ~><Value> (pub1: AnyPublisher<Value, Never>, pub2: inout Published<Value>.Publisher) {
    pub1.assign(to: &pub2)
}
