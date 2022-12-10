//
//  SearchView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2020/11/30.
//

import SwiftUI
import WebKit

struct SearchView: View {
    @ObservedObject var vm = vmSettings
    @ObservedObject var webViewStore = WebViewStore()
    @ObservedObject var dictStore = DictStoreUI()
    var wvDict: WKWebView { webViewStore.webView }

    var body: some View {
        VStack {
            SearchBar(text: $dictStore.word, placeholder: "Word") {_ in dictStore.searchDict() }
            HStack {
                Picker("", selection: $vm.selectedLangIndex) {
                    ForEach(0..<vm.arrLanguages.count, id: \.self) {
                        Text(vm.arrLanguages[$0].LANGNAME)
                    }
                }
                .background(Color.pink)
                .tint(.white)
                .pickerStyle(MenuPickerStyle())
                .onChange(of: vm.selectedLangIndex) {
                    print("selectedLangIndex=\($0)")
                    Task {
                        await vm.updateLang()
                    }
                }
                Picker("", selection: $vm.selectedDictReferenceIndex) {
                    ForEach(0..<vm.arrDictsReference.count, id: \.self) {
                        Text(vm.arrDictsReference[$0].DICTNAME)
                    }
                }
                .background(Color.orange)
                .tint(.white)
                .pickerStyle(MenuPickerStyle())
                .onChange(of: vm.selectedDictReferenceIndex) {
                    if $0 == -1 {return}
                    print("selectedDictReferenceIndex=\($0)")
                    dictStore.dict = vm.arrDictsReference[$0]
                    dictStore.searchDict()
                }
            }
            WebView(webView: wvDict) {
                dictStore.onNavigationFinished()
            }
        }.onAppear {
            dictStore.vmSettings = vmSettings
            dictStore.wvDict = wvDict
            Task {
                await vm.getData()
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
