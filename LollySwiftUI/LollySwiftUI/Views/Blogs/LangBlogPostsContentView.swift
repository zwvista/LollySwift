//
//  LangBlogPostsContentView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2024/09/06.
//

import SwiftUI

struct LangBlogPostsContentView: View {
    @Binding var navPath: NavigationPath
    @StateObject var vm: LangBlogPostsContentViewModel
    @ObservedObject var vmGroups: LangBlogGroupsViewModel
    @EnvironmentObject var webViewStore: WebViewStore
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Picker("LangBlogPost", selection: $vm.selectedPostIndex) {
                ForEach(vm.arrPosts.indices, id: \.self) {
                    Text(vm.arrPosts[$0].TITLE)
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
        .onChange(of: vmGroups.postHtml) {
            webViewStore.webView.loadHTMLString(headString + $1, baseURL: nil)
        }
        .onDisappear {
            vmGroups.selectedPost = nil
        }
    }
}
