//
//  UnitBlogView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2024/09/06.
//

import SwiftUI

struct UnitBlogView: View {
    @Binding var navPath: NavigationPath
    @ObservedObject var vm = UnitBlogViewModel(settings: vmSettings, needCopy: false) {}
    @State var webViewStore = WebViewStore()
    var body: some View {
        VStack(spacing: 0) {
            Picker("Unit", selection: $vm.currentUnitIndex) {
                ForEach(vm.arrUnits.indices, id: \.self) {
                    Text(vm.arrUnits[$0].label)
                }
            }
            .modifier(PickerModifier(backgroundColor: Color.color3))
            .onChange(of: vm.currentUnitIndex) {
                Task {
                    await currentUnitIndexChanged()
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
                await currentUnitIndexChanged()
            }
        }
    }

    private func currentUnitIndexChanged() async {
        let content = await vmSettings.getBlogContent(unit: vm.selectedUnit)
        let str = BlogPostEditViewModel.markedToHtml(text: content)
        webViewStore.webView.loadHTMLString(str, baseURL: nil)
    }

    private func swipe(_ delta: Int) {
        vm.next(delta)
    }
}
