//
//  ContentView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2020/11/30.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var g = globalUser
    @State var isOpenSideMenu: Bool = false
    @State var bindTitle = titleSearch
    @State var navPath = NavigationPath()

    func getContentView(_ view: some View) -> some View {
        ZStack{
            NavigationStack(path: $navPath) {
                view
                    .navigationTitle(bindTitle)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(leading: (
                        Button(action: {
                            isOpenSideMenu.toggle()
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .imageScale(.large)
                        }))
            }
            SideMenuView(isOpen: $isOpenSideMenu, bindTitle: $bindTitle)
                .edgesIgnoringSafeArea(.all)
        }
    }

    var body: some View {
        if g.userid.isEmpty {
            LoginView()
        } else if bindTitle == titleSearch {
            getContentView(SearchView())
        } else if bindTitle == titleSettings {
            getContentView(SettingsView())
        } else if bindTitle == titleWordsUnit {
            getContentView(WordsUnitView(navPath: $navPath))
        } else if bindTitle == titlePhrasesUnit {
            getContentView(PhrasesUnitView(navPath: $navPath))
        } else if bindTitle == titleWordsReview {
            getContentView(WordsReviewView())
        } else if bindTitle == titlePhrasesReview {
            getContentView(PhrasesReviewView())
        } else if bindTitle == titleWordsTextbook {
            getContentView(WordsTextbookView(navPath: $navPath))
        } else if bindTitle == titlePhrasesTextbook {
            getContentView(PhrasesTextbookView(navPath: $navPath))
        } else if bindTitle == titleWordsLang {
            getContentView(WordsLangView(navPath: $navPath))
        } else if bindTitle == titlePhrasesLang {
            getContentView(PhrasesLangView(navPath: $navPath))
        } else if bindTitle == titlePatternsLang {
            getContentView(PatternsView(navPath: $navPath))
        } else if bindTitle == titleOnlineTextbooks {
            getContentView(OnlineTextbooksView(navPath: $navPath))
        } else if bindTitle == titleUnitBlogPosts {
            getContentView(UnitBlogPostsView(navPath: $navPath))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
