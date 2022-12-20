//
//  NSSegmentedControl+Combine.swift
//  CombineCommon
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

    @objc var selectedLabel: String {
        get {
            label(forSegment: selectedSegment)!
        }
        set {
            selectedSegment = (0..<segmentCount).first { label(forSegment: $0) == newValue } ?? 0
        }
    }
    var selectedLabelPublisher: AnyPublisher<String, Never> {
        Publishers.ControlProperty(control: self, keyPath: \.selectedLabel)
            .eraseToAnyPublisher()
    }
    var selectedLabelProperty: Publishers.ControlProperty2<NSSegmentedControl, String> {
        Publishers.ControlProperty2(control: self, getter: \.selectedLabelPublisher, setter: \.selectedLabel)
    }

    @objc var isOn: Bool {
        get {
            selectedSegment == 1
        }
        set {
            selectedSegment = newValue ? 1 : 0
        }
    }
    var isOnPublisher: AnyPublisher<Bool, Never> {
        Publishers.ControlProperty(control: self, keyPath: \.isOn)
            .eraseToAnyPublisher()
    }
    var isOnProperty: Publishers.ControlProperty2<NSSegmentedControl, Bool> {
        Publishers.ControlProperty2(control: self, getter: \.isOnPublisher, setter: \.isOn)
    }
}
