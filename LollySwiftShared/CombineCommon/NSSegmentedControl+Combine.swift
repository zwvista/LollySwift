//
//  NSSegmentedControl+Combine.swift
//  CombineMacExample
//
//  Created by 趙偉 on 2022/11/29.
//

import Cocoa
import Combine

extension NSSegmentedControl {
    var selectedSegmentPublisher: AnyPublisher<Int, Never> {
        Publishers.ControlProperty(control: self, keyPath: \.selectedSegment)
            .eraseToAnyPublisher()
    }
    var selectedSegmentProperty: Publishers.ControlProperty2<NSSegmentedControl, Int> {
        Publishers.ControlProperty2(control: self, getter: \.selectedSegmentPublisher, setter: \.selectedSegment)
    }

    @objc var selectLabel: String {
        get {
            label(forSegment: selectedSegment)!
        }
        set {
            selectedSegment = (0..<segmentCount).first { label(forSegment: $0) == newValue } ?? 0
        }
    }
    var selectLabelPublisher: AnyPublisher<String, Never> {
        Publishers.ControlProperty(control: self, keyPath: \.selectLabel)
            .eraseToAnyPublisher()
    }
    var selectLabelProperty: Publishers.ControlProperty2<NSSegmentedControl, String> {
        Publishers.ControlProperty2(control: self, getter: \.selectLabelPublisher, setter: \.selectLabel)
    }
}
