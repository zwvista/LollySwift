//
//  SideMenuView.swift
//  LollySwiftiOS
//
//  Created by 趙　偉 on 2021/01/12.
//  Copyright © 2021 趙 偉. All rights reserved.
//

import SwiftUI

struct ContentView2: View {
    @State var isOpenSideMenu: Bool = false
    @State var bindPage: LollyPage = .wordsUnit
    var body: some View {
        ZStack{
            NavigationView {
                Text("")
                    .navigationBarTitle("メイン画面")
                    .navigationBarItems(leading: (
                        Button(action: {
                            self.isOpenSideMenu.toggle()
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .imageScale(.large)
                    }))
            }

            SideMenuView(isOpen: $isOpenSideMenu, bindPage: $bindPage)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

struct ContentView2_Previews: PreviewProvider {
    static var previews: some View {
        ContentView2()
    }
}

enum LollyPage {
    case wordsUnit
    case phrasesUnit
    case wordsTextbook
    case phrasesTextbook
    case wordsLang
    case phrasesLang
}

// https://dev.classmethod.jp/articles/swiftui_overlay_sidemenu/
struct SideMenuView: View {
    @Binding var isOpen: Bool
    @Binding var bindPage: LollyPage
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
                    SideMenuContentView(topPadding: 100, systemName: "person", text: "Words in Unit", page: .wordsUnit, bindPage: $bindPage, isOpen: $isOpen)
                    SideMenuContentView(systemName: "bookmark", text: "Phrases in Unit", page: .wordsUnit, bindPage: $bindPage, isOpen: $isOpen)
                    SideMenuContentView(systemName: "gear", text: "Words in Unit", page: .wordsUnit, bindPage: $bindPage, isOpen: $isOpen)
                    SideMenuContentView(systemName: "person", text: "Words in Unit", page: .wordsUnit, bindPage: $bindPage, isOpen: $isOpen)
                    SideMenuContentView(systemName: "bookmark", text: "Phrases in Unit", page: .wordsUnit, bindPage: $bindPage, isOpen: $isOpen)
                    SideMenuContentView(systemName: "gear", text: "Setting", page: .wordsUnit, bindPage: $bindPage, isOpen: $isOpen)
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
    let page: LollyPage
    @Binding var bindPage: LollyPage
    @Binding var isOpen: Bool

    init(topPadding: CGFloat = 30, systemName: String, text: String, page: LollyPage, bindPage: Binding<LollyPage>, isOpen: Binding<Bool>) {
        self.topPadding = topPadding
        self.systemName = systemName
        self.page = page
        self._bindPage = bindPage
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
            self.bindPage = self.page
            self.isOpen = false
        }
    }
}
