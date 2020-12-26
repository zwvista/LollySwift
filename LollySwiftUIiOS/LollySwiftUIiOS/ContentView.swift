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
    var body: some View {
        VStack {
            SearchBar(text: $text, placeholder: "Word") {_ in }
            Picker("Dictionary", selection: $vm.selectedDictReference) {
                ForEach(vm.arrDictsReference, id: \.self) {
                    Text($0.DICTNAME).tag($0)
                }
            }
            WebView(req: ContentView.makeURLRequest())
        }
    }

    static func makeURLRequest() -> URLRequest {
        let request = URLRequest(url: URL(string: "about:blank")!)
        return request
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
