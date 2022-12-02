//
//  Publisher+UILabel.swift
//  CombineBind
//
//  Created by 趙偉 on 2022/12/01.
//

import UIKit
import Combine
import CombineCocoa

infix operator ~> : DefaultPrecedence

extension Published<String>.Publisher {
    func oneWayBind(label: UILabel) -> AnyCancellable {
        self.assign(to: \UILabel.text!, on: label)
    }
    public static func ~> (pub: Published<String>.Publisher, label: UILabel) -> AnyCancellable {
        pub.oneWayBind(label: label)
    }
}
