//
//  UnitBlogPostsView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2024/09/06.
//

import SwiftUI

struct UnitBlogPostsView: View {
    @Binding var navPath: NavigationPath
    @StateObject var vm = UnitBlogPostsViewModel(settings: vmSettings) {}
    @EnvironmentObject var webViewStore: WebViewStore
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Picker("Unit", selection: $vm.selectedUnitIndex) {
                ForEach(vm.arrUnits.indices, id: \.self) {
                    Text(vm.arrUnits[$0].label)
                }
            }
            .modifier(PickerModifier(backgroundColor: Color.color3))
            .onChange(of: vm.selectedUnitIndex) {
                Task {
                    await selectedUnitIndexChanged()
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
        .onAppear {
            Task {
                await selectedUnitIndexChanged()
            }
        }
    }

    private func selectedUnitIndexChanged() async {
        let content = await vmSettings.getBlogContent(unit: vm.selectedUnit)
        let str = BlogPostEditViewModel.markedToHtml(text: content)
        webViewStore.webView.loadHTMLString(headString + str, baseURL: nil)
    }

    private func swipe(_ delta: Int) {
        vm.next(delta)
    }
}
