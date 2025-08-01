//
//  WordsDictView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2020/11/30.
//

import SwiftUI
import WebKit

struct WordsDictView: View {
    @StateObject var vm: WordsDictViewModel
    @ObservedObject var vmS = vmSettings
    @EnvironmentObject var webViewStore: WebViewStore
    @StateObject var dictStore = DictStore()
    var wvDict: WKWebView { webViewStore.webView }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            HStack(spacing: 0) {
                Picker("", selection: $vm.selectedWordIndex) {
                    ForEach(vm.arrWords.indices, id: \.self) {
                        Text(vm.arrWords[$0])
                    }
                }
                .modifier(PickerModifier(backgroundColor: Color.color3))
                .onChange(of: vm.selectedWordIndex) {
                    selectedWordChanged()
                }
                Picker("", selection: $vmS.selectedDictReferenceIndex) {
                    ForEach(vmS.arrDictsReference.indices, id: \.self) {
                        Text(vmS.arrDictsReference[$0].DICTNAME)
                    }
                }
                .modifier(PickerModifier(backgroundColor: Color.color2))
                .onChange(of: vmS.selectedDictReferenceIndex) {
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
            dictStore.wvDict = wvDict
            selectedWordChanged()
        }
    }

    private func selectedWordChanged() {
        AppDelegate.speak(string: vm.selectedWord)
        dictStore.word = vm.selectedWord
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
