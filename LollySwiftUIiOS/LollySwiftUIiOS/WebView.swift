//
//  WebView.swift
//  LollySwiftUIiOS
//
//  Created by 趙　偉 on 2020/12/15.
//

import SwiftUI
import WebKit

// https://qiita.com/noby111/items/2830d9f9c76c83df79a1
struct WebView: UIViewControllerRepresentable {
    var req : URLRequest

    class Coodinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent : WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("load started")
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("load finished")
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print(error)
        }
    }

    func makeCoordinator() -> WebView.Coodinator {
        return Coodinator(self)
    }

    func makeUIViewController(context: Context) -> EmbeddedWebviewController {
        let webViewController = EmbeddedWebviewController(coordinator: context.coordinator)
        webViewController.loadUrl(req)

        return webViewController
    }

    func updateUIViewController(_ uiViewController: EmbeddedWebviewController, context: UIViewControllerRepresentableContext<WebView>) {

    }
}

class EmbeddedWebviewController: UIViewController {

    var webview: WKWebView

    public var delegate: WebView.Coordinator? = nil

    init(coordinator: WebView.Coordinator) {
        self.delegate = coordinator
        self.webview = WKWebView()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.webview = WKWebView()
        super.init(coder: coder)
    }

    public func loadUrl(_ req: URLRequest) {
        webview.load(req)
    }

    override func loadView() {
        self.webview.navigationDelegate = self.delegate
        self.webview.uiDelegate = self.delegate
        view = webview
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

struct WebView_Previews: PreviewProvider {

    static var previews: some View {
        VStack{
            WebView(req: self.makeURLRequest())
        }
    }

    static func makeURLRequest() -> URLRequest {
        let request = URLRequest(url: URL(string: "https://www.google.co.jp")!)
        return request
    }
}
