//
//  PatternWebPagesBrowseView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/30.
//

import SwiftUI

struct PatternWebPagesBrowseView: View {
    @ObservedObject var vm: PatternsWebPagesViewModel
    @Binding var showBrowse: Bool
    @State var webViewStore = WebViewStore()
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Picker("", selection: $vm.currentWebPageIndex) {
                ForEach(vm.arrWebPages.indices, id: \.self) {
                    Text(vm.arrWebPages[$0].TITLE)
                }
            }
            .modifier(PickerModifier(backgroundColor: Color.color2))
            WebView(webView: webViewStore.webView) {}
        }
        .navigationTitle("Pattern Web Pages (Browse)")
        .onAppear {
            Task{
                await vm.getWebPages()
                currentWebPageChanged()
            }
        }
    }

    func currentWebPageChanged() {
        AppDelegate.speak(string: vm.currentWebPage.TITLE)
        webViewStore.webView.load(URLRequest(url: URL(string: vm.currentWebPage.URL)!))
    }
}

//struct PatternWebPagesBrowseView_Previews: PreviewProvider {
//    static var previews: some View {
//        PatternWebPagesBrowseView()
//    }
//}
