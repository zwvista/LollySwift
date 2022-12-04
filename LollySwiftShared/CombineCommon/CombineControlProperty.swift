//
//  CombineControlProperty.swift
//  CombineCocoa
//
//  Created by Shai Mishali on 01/08/2019.
//  Copyright © 2020 Combine Community. All rights reserved.
//

#if os(macOS)

import Cocoa
import Combine

// MARK: - Publisher
public extension Combine.Publishers {
    /// A Control Property is a publisher that emits the value at the provided keypath
    /// whenever the specific control events are triggered. It also emits the keypath's
    /// initial value upon subscription.
    struct ControlProperty<Control: NSControl, Value>: Publisher {
        public typealias Output = Value
        public typealias Failure = Never

        private let control: Control
        private let keyPath: KeyPath<Control, Value>

        /// Initialize a publisher that emits the value at the specified keypath
        /// whenever any of the provided Control Events trigger.
        ///
        /// - parameter control: UI Control.
        /// - parameter keyPath: A Key Path from the UI Control to the requested value.
        public init(control: Control,
                    keyPath: KeyPath<Control, Value>) {
            self.control = control
            self.keyPath = keyPath
        }

        public func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
            let subscription = Subscription(subscriber: subscriber,
                                            control: control,
                                            keyPath: keyPath)

            subscriber.receive(subscription: subscription)
        }
    }
}

// MARK: - Subscription
extension Combine.Publishers.ControlProperty {
    private final class Subscription<S: Subscriber, Control: NSControl, Value>: Combine.Subscription where S.Input == Value {
        private var subscriber: S?
        weak private var control: Control?
        let keyPath: KeyPath<Control, Value>
        private var didEmitInitial = false

        init(subscriber: S, control: Control, keyPath: KeyPath<Control, Value>) {
            self.subscriber = subscriber
            self.control = control
            self.keyPath = keyPath
            control.target = self
            control.action = #selector(processControlEvent)
        }

        func request(_ demand: Subscribers.Demand) {
            // Emit initial value upon first demand request
            if !didEmitInitial,
                demand > .none,
                let control = control,
                let subscriber = subscriber {
                _ = subscriber.receive(control[keyPath: keyPath])
                didEmitInitial = true
            }

            // We don't care about the demand at this point.
            // As far as we're concerned - UIControl events are endless until the control is deallocated.
        }

        func cancel() {
            control?.target = nil
            control?.action = nil
            subscriber = nil
        }

        @objc private func processControlEvent() {
            guard let control = control else { return }
            _ = subscriber?.receive(control[keyPath: keyPath])
        }
    }
}
#endif
