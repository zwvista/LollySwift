//
//  SearchView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2020/11/30.
//

import SwiftUI
import WebKit

struct SearchView: View {
    @ObservedObject var vm = vmSettings
    @EnvironmentObject var webViewStore: WebViewStore
    @StateObject var dictStore = DictStore()
    var wvDict: WKWebView { webViewStore.webView }

    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $dictStore.word, placeholder: "Word") { _ in
                dictStore.searchDict()
            }
            HStack(spacing: 0) {
                Picker("", selection: $vm.selectedLangIndex) {
                    ForEach(vm.arrLanguages.indices, id: \.self) {
                        Text(vm.arrLanguages[$0].LANGNAME)
                    }
                }
                .modifier(PickerModifier(backgroundColor: Color.color3))
                Picker("", selection: $vm.selectedDictReferenceIndex) {
                    ForEach(vm.arrDictsReference.indices, id: \.self) {
                        Text(vm.arrDictsReference[$0].DICTNAME)
                    }
                }
                .modifier(PickerModifier(backgroundColor: Color.color2))
                .onChange(of: vm.selectedDictReferenceIndex) {
                    guard $1 != -1 else {return}
                    dictStore.dict = vmSettings.selectedDictReference
                    dictStore.searchDict()
                }
            }
            WebView(webView: wvDict) {
                dictStore.onNavigationFinished()
            }
        }
        .toolbar {
            Button("LOGOUT") {
                globalUser.remove()
            }
        }
        .onAppear {
            dictStore.wvDict = wvDict
            Task {
                await vm.getData()
            }
        }
    }
}
