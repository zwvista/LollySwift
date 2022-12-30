//
//  PatternWebPagesBrowseView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/30.
//

import SwiftUI

struct PatternWebPagesBrowseView: View {
    @ObservedObject var vm: PatternsWebPagesViewModel
    @State var webViewStore = WebViewStore()
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Picker("", selection: $vm.currentWebPageIndex) {
                ForEach(vm.arrWebPages.indices, id: \.self) {
                    Text(vm.arrWebPages[$0].TITLE)
                }
            }
            .modifier(PickerModifier(backgroundColor: Color.color2))
            WebView(webView: webViewStore.webView) {}
            // https://stackoverflow.com/questions/60885532/how-to-detect-swiping-up-down-left-and-right-with-swiftui-on-a-view
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
        .navigationTitle("Pattern Web Pages (Browse)")
        .onAppear {
            Task{
                await vm.getWebPages()
                currentWebPageChanged()
            }
        }
    }

    private func currentWebPageChanged() {
        AppDelegate.speak(string: vm.currentWebPage.TITLE)
        webViewStore.webView.load(URLRequest(url: URL(string: vm.currentWebPage.URL)!))
    }

    private func swipe(_ delta: Int) {
        vm.next(delta)
        currentWebPageChanged()
    }
}
