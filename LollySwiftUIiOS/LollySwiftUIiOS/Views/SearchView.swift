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
                Picker(selection: $vm.selectedLangIndex, label: Text( vm.selectedLang.LANGNAME.defaultIfEmpty("Language"))) {
                    ForEach(0..<vm.arrLanguages.count, id: \.self) {
                        Text(vm.arrLanguages[$0].LANGNAME)
                    }
                }
                .padding().background(Color.green)
                .pickerStyle(MenuPickerStyle())
                .onChange(of: vm.selectedLangIndex) {
                    print("selectedLangIndex=\($0)")
                    Task {
                        await vm.updateLang()
                    }
                }
                Picker(selection: $vm.selectedDictReferenceIndex, label: Text(vm.selectedDictReference.DICTNAME.defaultIfEmpty("Dictionary"))) {
                    ForEach(0..<vm.arrDictsReference.count, id: \.self) {
                        Text(vm.arrDictsReference[$0].DICTNAME)
                    }
                }
                .padding().background(Color.orange)
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
