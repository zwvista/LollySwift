//
//  WebView.swift
//  LollySwiftUI
//
//  Created by 趙　偉 on 2020/12/15.
//

import SwiftUI
import Combine
import WebKit

@MainActor
class SharedProcessPool {
    static let shared = WKProcessPool()
}

// https://github.com/kylehickinson/SwiftUI-WebView/blob/master/Sources/WebView/WebView.swift
// https://qiita.com/noby111/items/2830d9f9c76c83df79a1
@MainActor
@dynamicMemberLookup
class WebViewStore: ObservableObject {
  @Published var webView: WKWebView {
    didSet {
      setupObservers()
    }
  }

    init(webView: WKWebView = WKWebView(frame: .zero, configuration: WebViewStore.makeConfig())) {
    self.webView = webView
    setupObservers()
  }

    private static func makeConfig() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        config.processPool = SharedProcessPool.shared
        return config
    }

  private func setupObservers() {
    func subscriber<Value>(for keyPath: KeyPath<WKWebView, Value>) -> NSKeyValueObservation {
      return webView.observe(keyPath, options: [.prior]) {[weak self] _, change in
          guard let self else { return }
        if change.isPrior {
          self.objectWillChange.send()
        }
      }
    }
    // Setup observers for all KVO compliant properties
    observers = [
      subscriber(for: \.title),
      subscriber(for: \.url),
      subscriber(for: \.isLoading),
      subscriber(for: \.estimatedProgress),
      subscriber(for: \.hasOnlySecureContent),
      subscriber(for: \.serverTrust),
      subscriber(for: \.canGoBack),
      subscriber(for: \.canGoForward)
    ]
      if #available(iOS 15.0, macOS 12.0, *) {
        observers += [
          subscriber(for: \.themeColor),
          subscriber(for: \.underPageBackgroundColor),
          subscriber(for: \.microphoneCaptureState),
          subscriber(for: \.cameraCaptureState)
        ]
      }
  #if swift(>=5.7)
      if #available(iOS 16.0, macOS 13.0, *) {
        observers.append(subscriber(for: \.fullscreenState))
      }
  #else
      if #available(iOS 15.0, macOS 12.0, *) {
        observers.append(subscriber(for: \.fullscreenState))
      }
  #endif
    }
    
    private var observers: [NSKeyValueObservation] = []
    
    public subscript<T>(dynamicMember keyPath: KeyPath<WKWebView, T>) -> T {
      webView[keyPath: keyPath]
    }
  }

/// A container for using a WKWebView in SwiftUI
struct WebView: View, UIViewRepresentable {
  /// The WKWebView to display
  let webView: WKWebView
    let onNavigationFinished: () -> Void

  typealias UIViewType = UIViewContainerView<WKWebView>

    class Coodinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        let parent : WebView
        let onNavigationFinished: () -> Void

        init(_ parent: WebView, onNavigationFinished: @escaping () -> Void) {
            self.parent = parent
            self.onNavigationFinished = onNavigationFinished
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("load started")
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("load finished")
            onNavigationFinished()
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print(error)
        }
    }

    func makeCoordinator() -> WebView.Coodinator {
        return Coodinator(self, onNavigationFinished: onNavigationFinished)
    }

  func makeUIView(context: UIViewRepresentableContext<WebView>) -> WebView.UIViewType {
    return UIViewContainerView()
  }

  func updateUIView(_ uiView: WebView.UIViewType, context: UIViewRepresentableContext<WebView>) {
    // If its the same content view we don't need to update.
    if uiView.contentView !== webView {
      uiView.contentView = webView
        webView.navigationDelegate = context.coordinator
    }
  }
}

/// A UIView which simply adds some view to its view hierarchy
class UIViewContainerView<ContentView: UIView>: UIView {
  var contentView: ContentView? {
    willSet {
        if let contentView = contentView, contentView !== newValue {
            contentView.removeFromSuperview()
        }
    }
    didSet {
      if let contentView = contentView, contentView.superview != self {
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
          contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
          contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
          contentView.topAnchor.constraint(equalTo: topAnchor),
          contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
      }
    }
  }
}

struct WebView_Previews: PreviewProvider {
    static var webViewStore = WebViewStore()

    static var previews: some View {
        VStack{
            WebView(webView: webViewStore.webView, onNavigationFinished: {})
        }
        .onAppear {
            webViewStore.webView.load(URLRequest(url: URL(string: "https://apple.com")!))
        }
    }
}
