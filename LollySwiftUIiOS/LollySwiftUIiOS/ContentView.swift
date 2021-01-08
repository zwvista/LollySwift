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
    @State var dictStatus = DictWebViewStatus.ready
    var body: some View {
        VStack {
            SearchBar(text: $word, placeholder: "Word") {_ in }
            HStack {
                // https://stackoverflow.com/questions/59348093/picker-for-optional-data-type-in-swiftui
                Picker(selection: $vm.selectedDictReference, label: Text(vm.selectedDictReference?.DICTNAME ?? "Choose a Dictionary")) {
                    ForEach(vm.arrDictsReference, id: \.self) {
                        Text($0.DICTNAME).tag($0 as MDictionary?)
                    }
                }
                .padding().background(Color.orange)
                .pickerStyle(MenuPickerStyle())
                .onChange(of: vm.selectedDictReference) {_ in
                    searchDict()
                }
            }
            WebView(webView: wvDict, onNavigationFinished: onNavigationFinished)
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
    
    func onNavigationFinished() {
        guard dictStatus != .ready else {return}
        let item = vmSettings.selectedDictReference!
        // https://stackoverflow.com/questions/34751860/get-html-from-wkwebview-in-swift
        switch dictStatus {
        case .automating:
            let s = item.AUTOMATION.replacingOccurrences(of: "{0}", with: word)
            wvDict.evaluateJavaScript(s) { (html: Any?, error: Error?) in
                self.dictStatus = .ready
                if item.DICTTYPENAME == "OFFLINE-ONLINE" {
                    dictStatus = .navigating
                }
            }
        case .navigating:
            wvDict.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html: Any?, error: Error?) in
                let html = html as! String
                print(html)
                let str = item.htmlString(html, word: word, useTemplate2: true)
                wvDict.loadHTMLString(str, baseURL: nil)
                dictStatus = .ready
            }
        default: break
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
