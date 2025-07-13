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
    @State var webViewStore = WebViewStore()
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Picker("LangBlogPost", selection: $vm.selectedLangBlogPostIndex) {
                ForEach(vm.arrLangBlogPosts.indices, id: \.self) {
                    Text(vm.arrLangBlogPosts[$0].TITLE)
                }
            }
            .modifier(PickerModifier(backgroundColor: Color.color3))
            .onChange(of: vm.selectedLangBlogPostIndex) {
                Task {
                    await selectedLangBlogPostIndexChanged()
                }
            }
            WebView(webView: webViewStore.webView) {}
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onEnded { value in
                        if value.translation.width < 0 {
                            // left
                            swipe(-1)
                        }
                        if value.translation.width > 0 {
                            // right
                            swipe(1)
                        }
                    }
            )
        }
        .navigationTitle("Language Blog Posts (Content)")
        .onAppear {
            Task {
                await selectedLangBlogPostIndexChanged()
            }
        }
    }

    private func selectedLangBlogPostIndexChanged() async {
        let content = BlogPostEditViewModel.markedToHtml(text: vmGroup.postContent)
        webViewStore.webView.loadHTMLString(content, baseURL: nil)
    }

    private func swipe(_ delta: Int) {
        vm.next(delta)
    }
}
