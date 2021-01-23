//
//  SideMenuView.swift
//  LollySwiftiOS
//
//  Created by 趙　偉 on 2021/01/12.
//  Copyright © 2021 趙 偉. All rights reserved.
//

import SwiftUI

let titleSearch = "Search"
let titleSettings = "Settings"
let titleWordsUnit = "Words in Unit"
let titlePhrasesUnit = "Phrases in Unit"
let titleWordsTitlebook = "Words in Titlebook"
let titlePhrasesTitlebook = "Phrases in Titlebook"
let titleWordsLang = "Words in Language"
let titlePhrasesLang = "Phrases in Language"

// https://dev.classmethod.jp/articles/swiftui_overlay_sidemenu/
struct SideMenuView: View {
    @Binding var isOpen: Bool
    @Binding var bindTitle: String
    let width: CGFloat = 270

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                EmptyView()
            }
            .background(Color.gray.opacity(0.3))
            .opacity(self.isOpen ? 1.0 : 0.0)
            .opacity(1.0)
            .animation(.easeIn(duration: 0.25))
            .onTapGesture {
                self.isOpen = false
            }

            HStack {
                VStack() {
                    SideMenuContentView(topPadding: 100, systemName: "gear", title: titleSearch, bindTitle: $bindTitle, isOpen: $isOpen)
                    SideMenuContentView(systemName: "gear", title: titleSettings, bindTitle: $bindTitle, isOpen: $isOpen)
                    SideMenuContentView(systemName: "person", title: titleWordsUnit, bindTitle: $bindTitle, isOpen: $isOpen)
                    SideMenuContentView(systemName: "bookmark", title: titlePhrasesUnit, bindTitle: $bindTitle, isOpen: $isOpen)
                    SideMenuContentView(systemName: "gear", title: titleWordsTitlebook, bindTitle: $bindTitle, isOpen: $isOpen)
                    SideMenuContentView(systemName: "person", title: titlePhrasesTitlebook, bindTitle: $bindTitle, isOpen: $isOpen)
                    SideMenuContentView(systemName: "bookmark", title: titleWordsLang, bindTitle: $bindTitle, isOpen: $isOpen)
                    SideMenuContentView(systemName: "bookmark", title: titlePhrasesLang, bindTitle: $bindTitle, isOpen: $isOpen)
                    Spacer()
                }
                .frame(width: width)
                .background(Color(UIColor.systemGray6))
                .offset(x: self.isOpen ? 0 : -self.width)
                .animation(.easeIn(duration: 0.25))
                Spacer()
            }
        }
    }
}

struct SideMenuContentView: View {
    let topPadding: CGFloat
    let systemName: String
    let title: String
    @Binding var bindTitle: String
    @Binding var isOpen: Bool

    init(topPadding: CGFloat = 30, systemName: String, title: String, bindTitle: Binding<String>, isOpen: Binding<Bool>) {
        self.topPadding = topPadding
        self.systemName = systemName
        self._bindTitle = bindTitle
        self._isOpen = isOpen
        self.title = title
    }

    var body: some View {
        HStack {
            Image(systemName: systemName)
                .foregroundColor(.gray)
                .imageScale(.large)
                .frame(width: 32.0)
            Text(title)
                .foregroundColor(.gray)
                .font(.headline)
            Spacer()
        }
        .padding(.top, topPadding)
        .padding(.leading, 32)
        .onTapGesture {
            self.bindTitle = self.title
            self.isOpen = false
        }
    }
}
