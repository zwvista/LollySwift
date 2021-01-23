//
//  SideMenuView.swift
//  LollySwiftiOS
//
//  Created by 趙　偉 on 2021/01/12.
//  Copyright © 2021 趙 偉. All rights reserved.
//

import SwiftUI

let textSearch = "Search"
let textSettings = "Settings"
let textWordsUnit = "Words in Unit"
let textPhrasesUnit = "Phrases in Unit"
let textWordsTextbook = "Words in Textbook"
let textPhrasesTextbook = "Phrases in Textbook"
let textWordsLang = "Words in Language"
let textPhrasesLang = "Phrases in Language"

// https://dev.classmethod.jp/articles/swiftui_overlay_sidemenu/
struct SideMenuView: View {
    @Binding var isOpen: Bool
    @Binding var bindText: String
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
                    SideMenuContentView(topPadding: 100, systemName: "gear", text: textSearch, bindText: $bindText, isOpen: $isOpen)
                    SideMenuContentView(systemName: "gear", text: textSettings, bindText: $bindText, isOpen: $isOpen)
                    SideMenuContentView(systemName: "person", text: textWordsUnit, bindText: $bindText, isOpen: $isOpen)
                    SideMenuContentView(systemName: "bookmark", text: textPhrasesUnit, bindText: $bindText, isOpen: $isOpen)
                    SideMenuContentView(systemName: "gear", text: textWordsTextbook, bindText: $bindText, isOpen: $isOpen)
                    SideMenuContentView(systemName: "person", text: textPhrasesTextbook, bindText: $bindText, isOpen: $isOpen)
                    SideMenuContentView(systemName: "bookmark", text: textWordsLang, bindText: $bindText, isOpen: $isOpen)
                    SideMenuContentView(systemName: "bookmark", text: textPhrasesLang, bindText: $bindText, isOpen: $isOpen)
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
    let text: String
    @Binding var bindText: String
    @Binding var isOpen: Bool

    init(topPadding: CGFloat = 30, systemName: String, text: String, bindText: Binding<String>, isOpen: Binding<Bool>) {
        self.topPadding = topPadding
        self.systemName = systemName
        self._bindText = bindText
        self._isOpen = isOpen
        self.text = text
    }

    var body: some View {
        HStack {
            Image(systemName: systemName)
                .foregroundColor(.gray)
                .imageScale(.large)
                .frame(width: 32.0)
            Text(text)
                .foregroundColor(.gray)
                .font(.headline)
            Spacer()
        }
        .padding(.top, topPadding)
        .padding(.leading, 32)
        .onTapGesture {
            self.bindText = self.text
            self.isOpen = false
        }
    }
}
