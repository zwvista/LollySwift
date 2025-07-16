//
//  PatternsWebPageView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2022/12/30.
//

import SwiftUI

struct PatternsWebPageView: View {
    @StateObject var vm: PatternsWebPageViewModel
    @EnvironmentObject var webViewStore: WebViewStore
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Picker("", selection: $vm.selectedPatternIndex) {
                ForEach(vm.arrPatterns.indices, id: \.self) {
                    Text(vm.arrPatterns[$0].PATTERN)
                }
            }
            .modifier(PickerModifier(backgroundColor: Color.color3))
            .onChange(of: vm.selectedPatternIndex) {
                selectedPatternChanged()
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
            selectedPatternChanged()
        }
    }

    private func selectedPatternChanged() {
        AppDelegate.speak(string: vm.selectedPattern.TITLE)
        webViewStore.webView.load(URLRequest(url: URL(string: vm.selectedPattern.URL)!))
    }

    private func swipe(_ delta: Int) {
        vm.next(delta)
    }
}
