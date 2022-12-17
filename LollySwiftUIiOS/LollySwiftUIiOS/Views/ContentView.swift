//
//  ContentView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2020/11/30.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var g = globalUser
    @State var isOpenSideMenu: Bool = false
    @State var bindTitle = titleSearch
    
    func getContentView(_ view: some View) -> some View {
        ZStack{
            NavigationView {
                view
                    .navigationTitle(bindTitle)
                    .navigationBarItems(leading: (
                        Button(action: {
                            self.isOpenSideMenu.toggle()
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
            getContentView(WordsUnitView())
        } else if bindTitle == titlePhrasesUnit {
            getContentView(PhrasesUnitView())
        } else if bindTitle == titleWordsLang {
            getContentView(WordsLangView())
        } else if bindTitle == titlePhrasesLang {
            getContentView(PhrasesLangView())
        } else if bindTitle == titlePatternsLang {
            getContentView(PatternsView())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
