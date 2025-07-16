//
//  OnlineTextbooksWebPageView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2022/12/30.
//

import SwiftUI

struct OnlineTextbooksWebPageView: View {
    @StateObject var vm: OnlineTextbooksWebPageViewModel
    @EnvironmentObject var webViewStore: WebViewStore
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Picker("", selection: $vm.selectedOnlineTextbookIndex) {
                ForEach(vm.arrOnlineTextbooks.indices, id: \.self) {
                    Text(vm.arrOnlineTextbooks[$0].TITLE)
                }
            }
            .modifier(PickerModifier(backgroundColor: Color.color3))
            .onChange(of: vm.selectedOnlineTextbookIndex) {
                selectedOnlineTextbookChanged()
            }
            WebView(webView: webViewStore.webView) {}
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onEnded { value in
                        if value.translation.width < 0 {
                            // left
                            swipe(-1)
                        }
                        if value.translation.width > 0 {
                            // right
                            swipe(1)
                        }
                    }
            )
        }
        .navigationTitle("Online Textbooks(Web Page)")
        .onAppear {
            selectedOnlineTextbookChanged()
        }
    }

    private func selectedOnlineTextbookChanged() {
        AppDelegate.speak(string: vm.selectedOnlineTextbook.TITLE)
        webViewStore.webView.load(URLRequest(url: URL(string: vm.selectedOnlineTextbook.URL)!))
    }

    private func swipe(_ delta: Int) {
        vm.next(delta)
    }
}
