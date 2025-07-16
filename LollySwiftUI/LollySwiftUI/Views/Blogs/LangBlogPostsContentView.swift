//
//  LangBlogPostsContentView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2024/09/06.
//

import SwiftUI

struct LangBlogPostsContentView: View {
    @Binding var navPath: NavigationPath
    @ObservedObject var vm: LangBlogPostsContentViewModel
    @ObservedObject var vmGroup: LangBlogGroupsViewModel
    @EnvironmentObject var webViewStore: WebViewStore
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Picker("LangBlogPost", selection: $vm.selectedLangBlogPostIndex) {
                ForEach(vm.arrLangBlogPosts.indices, id: \.self) {
                    Text(vm.arrLangBlogPosts[$0].TITLE)
                }
            }
            .modifier(PickerModifier(backgroundColor: Color.color3))
            WebView(webView: webViewStore.webView) {}
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onEnded { value in
                        if value.translation.width < 0 {
                            // left
                            vm.next(-1)
                        }
                        if value.translation.width > 0 {
                            // right
                            vm.next(1)
                        }
                    }
            )
        }
        .navigationTitle("Language Blog Posts (Content)")
        .onChange(of: vmGroup.postHtml) {
            webViewStore.webView.loadHTMLString(headString + $1, baseURL: nil)
        }
        .onDisappear {
            vmGroup.selectedPost = nil
        }
    }
}
