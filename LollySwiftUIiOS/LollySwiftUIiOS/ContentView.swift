//
//  ContentView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2020/11/30.
//

import SwiftUI

struct ContentView: View {
    @State var text = ""
    var body: some View {
        VStack {
            SearchBar(text: $text, placeholder: "Word") {_ in }
                .padding()
            WebView(req: ContentView.makeURLRequest())
        }
    }

    static func makeURLRequest() -> URLRequest {
        let request = URLRequest(url: URL(string: "https://www.google.co.jp")!)
        return request
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
