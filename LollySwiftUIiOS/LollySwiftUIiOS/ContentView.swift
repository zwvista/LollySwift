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
    let disposeBag = DisposeBag()

    var body: some View {
        VStack {
            SearchBar(text: $dictStore.word, placeholder: "Word") {_ in dictStore.searchDict() }
            HStack {
                Picker(selection: $vm.selectedLang, label: Text(vm.selectedLang.LANGNAME.defaultIfEmpty("Language"))) {
                    ForEach(vm.arrLanguages, id: \.self) {
                        Text($0.LANGNAME)
                    }
                }
                .padding().background(Color.green)
                .pickerStyle(MenuPickerStyle())
                .onChange(of: vm.selectedLang) {
                    vmSettings.setSelectedLang($0).subscribe() ~ disposeBag
                }
                Picker(selection: $vm.selectedDictReference, label: Text(vm.selectedDictReference.DICTNAME.defaultIfEmpty( "Dictionary"))) {
                    ForEach(vm.arrDictsReference, id: \.self) {
                        Text($0.DICTNAME)
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
            vm.getData().subscribe() ~ disposeBag
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
