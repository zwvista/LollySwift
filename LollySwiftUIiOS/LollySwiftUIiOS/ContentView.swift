//
//  ContentView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2020/11/30.
//

import SwiftUI

struct ContentView: View {
    @State var showLogin = globalUser.userid.isEmpty
    @State var isOpenSideMenu: Bool = false
    @State var bindTitle = titleWordsUnit
    var body: some View {
        if showLogin {
            LoginView(showLogin: $showLogin)
        } else {
            ZStack{
                NavigationView {
                    SearchView()
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
