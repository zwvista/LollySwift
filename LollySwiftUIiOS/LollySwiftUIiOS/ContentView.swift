//
//  ContentView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2020/11/30.
//

import SwiftUI
import RxSwift
import WebKit

struct ContentView: View {
    @ObservedObject var vm = vmSettings
    @ObservedObject var webViewStore = WebViewStore()
    @ObservedObject var dictStore = DictStoreUI()
    var wvDict: WKWebView { webViewStore.webView }
    var body: some View {
        VStack {
            SearchBar(text: $dictStore.word, placeholder: "Word") {_ in dictStore.searchDict() }
            HStack {
                // https://stackoverflow.com/questions/59348093/picker-for-optional-data-type-in-swiftui
                Picker(selection: $vm.selectedDictReference, label: Text(vm.selectedDictReference?.DICTNAME ?? "Choose a Dictionary")) {
                    ForEach(vm.arrDictsReference, id: \.self) {
                        Text($0.DICTNAME).tag($0 as MDictionary?)
                    }
                }
                .padding().background(Color.orange)
                .pickerStyle(MenuPickerStyle())
                .onChange(of: vm.selectedDictReference) {
                    dictStore.dict = $0
                    dictStore.searchDict()
                }
            }
            WebView(webView: wvDict) {
                dictStore.onNavigationFinished()
            }
        }.onAppear {
            dictStore.vmSettings = vmSettings
            dictStore.wvDict = wvDict
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
