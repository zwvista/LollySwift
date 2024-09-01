//
//  OnlineTextbooksWebPageView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2022/12/30.
//

import SwiftUI

struct OnlineTextbooksWebPageView: View {
    @State var item: MOnlineTextbook
    @State var webViewStore = WebViewStore()
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Button(item.TITLE) {}
            .modifier(PickerModifier(backgroundColor: Color.color2))
            WebView(webView: webViewStore.webView) {}
        }
        .navigationTitle("Online Textbooks(Web Page)")
        .onAppear {
            AppDelegate.speak(string: item.TITLE)
            webViewStore.webView.load(URLRequest(url: URL(string: item.URL)!))
        }
    }
}
