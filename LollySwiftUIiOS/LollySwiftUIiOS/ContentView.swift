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
    @State var word = ""
    @ObservedObject var webViewStore = WebViewStore()
    @State var status = DictWebViewStatus.ready
    let disposeBag = DisposeBag()
    var wvDict: WKWebView { webViewStore.webView }
    var body: some View {
        VStack {
            SearchBar(text: $word, placeholder: "Word") {_ in }
            // https://stackoverflow.com/questions/59348093/picker-for-optional-data-type-in-swiftui
            Picker(selection: $vm.selectedDictReference, label: Text(vm.selectedDictReference?.DICTNAME ?? "Choose a Dictionary")) {
                ForEach(vm.arrDictsReference, id: \.self) {
                    Text($0.DICTNAME).tag($0 as MDictionary?)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: vm.selectedDictReference) {_ in
                searchDict()
            }
            WebView(webView: wvDict)
        }
    }
    
    func searchDict() {
        let item = vmSettings.selectedDictReference!
        let url = item.urlString(word: word, arrAutoCorrect: vmSettings.arrAutoCorrect)
        if item.DICTTYPENAME == "OFFLINE" {
            wvDict.load(URLRequest(url: URL(string: "about:blank")!))
            RestApi.getHtml(url: url).subscribe(onNext: { html in
                print(html)
                let str = item.htmlString(html, word: word, useTemplate2: true)
                wvDict.loadHTMLString(str, baseURL: nil)
            }) ~ disposeBag
        } else {
            wvDict.load(URLRequest(url: URL(string: url)!))
            if item.DICTTYPENAME == "OFFLINE-ONLINE" {
                status = .navigating
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
