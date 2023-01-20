//
//  WordsDictView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2020/11/30.
//

import SwiftUI
import WebKit

struct WordsDictView: View {
    @StateObject var vm: WordsDictViewModel
    @ObservedObject var vmS = vmSettings
    @StateObject var webViewStore = WebViewStore()
    @StateObject var dictStore = DictStore()
    var wvDict: WKWebView { webViewStore.webView }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            HStack(spacing: 0) {
                Picker("", selection: $vm.currentWordIndex) {
                    ForEach(vm.arrWords.indices, id: \.self) {
                        Text(vm.arrWords[$0])
                    }
                }
                .modifier(PickerModifier(backgroundColor: Color.color3))
                .onChange(of: vm.currentWordIndex) { _ in
                    currentWordChanged()
                }
                Picker("", selection: $vmS.selectedDictReferenceIndex) {
                    ForEach(vmS.arrDictsReference.indices, id: \.self) {
                        Text(vmS.arrDictsReference[$0].DICTNAME)
                    }
                }
                .modifier(PickerModifier(backgroundColor: Color.color2))
                .onChange(of: vmS.selectedDictReferenceIndex) { _ in
                    selectDictChanged()
                }
            }
            WebView(webView: wvDict) {
                dictStore.onNavigationFinished()
            }
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
        .onAppear {
            dictStore.vmSettings = vmSettings
            dictStore.wvDict = wvDict
            currentWordChanged()
        }
    }

    private func currentWordChanged() {
        AppDelegate.speak(string: vm.currentWord)
        dictStore.word = vm.currentWord
        selectDictChanged()
    }

    private func selectDictChanged() {
        dictStore.dict = vmSettings.selectedDictReference
        dictStore.searchDict()
    }

    private func swipe(_ delta: Int) {
        vm.next(delta)
    }
}
