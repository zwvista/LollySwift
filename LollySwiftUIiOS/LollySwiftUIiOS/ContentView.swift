//
//  ContentView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2020/11/30.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var vm = vmSettings
    @State var text = ""
    @ObservedObject var webViewStore = WebViewStore()
    var body: some View {
        VStack {
            SearchBar(text: $text, placeholder: "Word") {_ in }
            Picker(selection: $vm.selectedDictReference, label: Text(vm.selectedDictReference.DICTNAME == "" ? "Choose a Dictionary" : vm.selectedDictReference.DICTNAME)) {
                ForEach(vm.arrDictsReference, id: \.self) {
                    Text($0.DICTNAME)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: vm.selectedDictReference) { print($0) }
            WebView(webView: webViewStore.webView)
        }.onAppear {
            self.webViewStore.webView.load(URLRequest(url: URL(string: "about:blank")!))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
