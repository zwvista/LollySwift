//
//  WordsDictView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2020/11/30.
//

import SwiftUI
import WebKit

struct WordsDictView: View {
    @StateObject var vm = WordsDictViewModel(settings: vmSettings, needCopy: false) {}
    @ObservedObject var vmS = vmSettings
    @ObservedObject var webViewStore = WebViewStore()
    @ObservedObject var dictStore = DictStore()
    @ObservedObject var listener = WordsDictViewListener()
    var wvDict: WKWebView { webViewStore.webView }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Picker("", selection: $vm.currentWordIndex) {
                    ForEach(vm.arrWords.indices, id: \.self) {
                        Text(vm.arrWords[$0])
                    }
                }
                .modifier(PickerModifier(backgroundColor: Color.color3))
                Picker("", selection: $vmS.selectedDictReferenceIndex) {
                    ForEach(vmS.arrDictsReference.indices, id: \.self) {
                        Text(vmS.arrDictsReference[$0].DICTNAME)
                    }
                }
                .modifier(PickerModifier(backgroundColor: Color.color2))
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
        }.onAppear {
            dictStore.vmSettings = vmSettings
            dictStore.wvDict = wvDict
            vmSettings.delegate = listener
            listener.dictStore = dictStore
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
        currentWordChanged()
    }
}

@MainActor
class WordsDictViewListener: NSObject, ObservableObject, SettingsViewModelDelegate {
    weak var dictStore: DictStore!
    func onUpdateDictReference() {
        dictStore.dict = vmSettings.selectedDictReference
        dictStore.searchDict()
    }

}
