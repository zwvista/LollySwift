//
//  PatternsView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2022/12/15.
//

import SwiftUI

struct LangBlogGroupsView: View {
    @Binding var navPath: NavigationPath
    @StateObject var vm = LangBlogGroupsViewModel()
    @State var showDetail = false
    @State var showItemMore = false
    // https://stackoverflow.com/questions/59235879/how-to-show-an-alert-when-the-user-taps-on-the-list-row-in-swiftui
    @State var selectedItem = MLangBlogGroup()
    var body: some View {
        VStack {
            SearchBar(text: $vm.groupFilter, placeholder: "Filter") { _ in }
            List {
                ForEach(vm.arrGroups, id: \.ID) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.GROUPNAME)
                                .font(.title)
                                .foregroundColor(Color.color2)
                        }
                        Spacer()
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .onTapGesture {
                                selectedItem = item
                                showPosts()
                            }
                    }
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        AppDelegate.speak(string: item.GROUPNAME)
                    }
                    .swipeActions(allowsFullSwipe: false) {
                        Button("More") {
                            selectedItem = item
                            showItemMore.toggle()
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await vm.reloadGroups()
            }
        }
        .refreshable {
            await vm.reloadGroups()
        }
        .alert(Text("Language Blog Group"), isPresented: $showItemMore, actions: {
            Button("Edit") {
                showDetail.toggle()
            }
            Button("Show Posts") {
                showPosts()
            }
        }, message: {
            Text(selectedItem.GROUPNAME)
        })
        .navigationTitle("Language Blog Groups")
        .navigationDestination(for: MLangBlogGroup.self) { item in
            LangBlogPostsListView(navPath: $navPath, vm: vm)
        }
        .sheet(isPresented: $showDetail) {
            LangBlogGroupsDetailView(item: selectedItem, showDetail: $showDetail)
        }
    }

    private func showPosts() {
        vm.selectedGroup = selectedItem
        navPath.append(selectedItem)
    }
}
