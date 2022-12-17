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
    @ObservedObject var dictStore = DictStore()
    @ObservedObject var listener = SearchViewListener()
    var wvDict: WKWebView { webViewStore.webView }

    var body: some View {
        VStack {
            SearchBar(text: $dictStore.word, placeholder: "Word") {_ in dictStore.searchDict() }
            HStack {
                Picker("", selection: $vm.selectedLangIndex) {
                    ForEach(vm.arrLanguages.indices, id: \.self) {
                        Text(vm.arrLanguages[$0].LANGNAME)
                    }
                }
                .background(Color("Color3"))
                .tint(.white)
                .pickerStyle(MenuPickerStyle())
                Picker("", selection: $vm.selectedDictReferenceIndex) {
                    ForEach(vm.arrDictsReference.indices, id: \.self) {
                        Text(vm.arrDictsReference[$0].DICTNAME)
                    }
                }
                .background(Color("Color2"))
                .tint(.white)
                .pickerStyle(MenuPickerStyle())
            }
            WebView(webView: wvDict) {
                dictStore.onNavigationFinished()
            }
        }.onAppear {
            dictStore.vmSettings = vmSettings
            dictStore.wvDict = wvDict
            vmSettings.delegate = listener
            listener.dictStore = dictStore
            Task {
                await vm.getData()
            }
        }
    }
}

@MainActor
class SearchViewListener: NSObject, ObservableObject, SettingsViewModelDelegate {
    weak var dictStore: DictStore!
    func onUpdateDictReference() {
        dictStore.dict = vmSettings.selectedDictReference
        dictStore.searchDict()
    }

}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
