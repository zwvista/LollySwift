//
//  NSSearchField+Rx.swift
//  RxCocoa
//

#if os(macOS)

import RxSwift
import RxCocoa

/// Delegate proxy for `NSSearchField`.
///
/// For more information take a look at `DelegateProxyType`.
class RxSearchFieldDelegateProxy
    : DelegateProxy<NSSearchField, NSSearchFieldDelegate>
    , DelegateProxyType 
    , NSSearchFieldDelegate {

    /// Typed parent object.
    public weak private(set) var searchField: NSSearchField?

    /// Initializes `RxSearchFieldDelegateProxy`
    ///
    /// - parameter searchField: Parent object for delegate proxy.
    init(searchField: NSSearchField) {
        self.searchField = searchField
        super.init(parentObject: searchField, delegateProxy: RxSearchFieldDelegateProxy.self)
    }

    public static func registerKnownImplementations() {
        self.register { RxSearchFieldDelegateProxy(searchField: $0) }
    }

    fileprivate let textSubject = PublishSubject<String?>()

    // MARK: Delegate methods
    open func controlTextDidChange(_ notification: Notification) {
        let textField: NSTextField = castOrFatalError(notification.object)
        let nextValue = textField.stringValue
        self.textSubject.on(.next(nextValue))
        _forwardToDelegate?.controlTextDidChange?(notification)
    }
    
    open func searchFieldDidStartSearching(_ searchField: NSSearchField) {
        let nextValue = searchField.stringValue
        self.textSubject.on(.next(nextValue))
        _forwardToDelegate?.searchFieldDidStartSearching?(searchField)
    }

    open func searchFieldDidEndSearching(_ searchField: NSSearchField) {
        let nextValue = searchField.stringValue
        self.textSubject.on(.next(nextValue))
        _forwardToDelegate?.searchFieldDidEndSearching?(searchField)
   }

    // MARK: Delegate proxy methods

    /// For more information take a look at `DelegateProxyType`.
    open class func currentDelegate(for object: ParentObject) -> NSSearchFieldDelegate? {
        return object.delegate
    }

    /// For more information take a look at `DelegateProxyType`.
    open class func setCurrentDelegate(_ delegate: NSSearchFieldDelegate?, to object: ParentObject) {
        object.delegate = delegate
    }
    
}

extension Reactive where Base: NSSearchField {

    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    public var delegateSearch: DelegateProxy<NSSearchField, NSSearchFieldDelegate> {
        return RxSearchFieldDelegateProxy.proxy(for: self.base)
    }
    
    /// Reactive wrapper for `text` property.
    public var textSearch: ControlProperty<String?> {
        let delegate = RxSearchFieldDelegateProxy.proxy(for: self.base)
        
        let source = Observable.deferred { [weak searchField = self.base] in
            delegate.textSubject.startWith(searchField?.stringValue)
        }.takeUntil(self.deallocated)

        let observer = Binder(self.base) { (control, value: String?) in
            control.stringValue = value ?? ""
        }

        return ControlProperty(values: source, valueSink: observer.asObserver())
    }
    
    public var searchFieldDidStartSearching: ControlEvent<()> {
        let source = delegateSearch.methodInvoked(#selector(RxSearchFieldDelegateProxy.searchFieldDidStartSearching(_:))).map {_ in }
        return ControlEvent(events: source)
    }
    
    public var searchFieldDidEndSearching: ControlEvent<()> {
        let source = delegateSearch.methodInvoked(#selector(RxSearchFieldDelegateProxy.searchFieldDidEndSearching(_:))).map {_ in }
        return ControlEvent(events: source)
    }
}

#endif
