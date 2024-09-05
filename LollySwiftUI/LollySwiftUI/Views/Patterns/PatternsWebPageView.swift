//
//  PatternsWebPageView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2022/12/30.
//

import SwiftUI

struct PatternsWebPageView: View {
    @StateObject var vm: PatternsWebPageViewModel
    @State var webViewStore = WebViewStore()
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Picker("", selection: $vm.currentPatternIndex) {
                ForEach(vm.arrPatterns.indices, id: \.self) {
                    Text(vm.arrPatterns[$0].PATTERN)
                }
            }
            .modifier(PickerModifier(backgroundColor: Color.color3))
            .onChange(of: vm.currentPatternIndex) {
                currentPatternChanged()
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
        .navigationTitle("Patterns Web Page")
        .onAppear {
            currentPatternChanged()
        }
    }

    private func currentPatternChanged() {
        AppDelegate.speak(string: vm.currentPattern.TITLE)
        webViewStore.webView.load(URLRequest(url: URL(string: vm.currentPattern.URL)!))
    }

    private func swipe(_ delta: Int) {
        vm.next(delta)
    }
}
