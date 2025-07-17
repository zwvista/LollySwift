//
//  PatternsView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2022/12/15.
//

import SwiftUI

struct LangBlogPostsListView: View {
    @Binding var navPath: NavigationPath
    @StateObject var vm: LangBlogGroupsViewModel
    @State var showDetail = false
    @State var showItemMore = false
    // https://stackoverflow.com/questions/59235879/how-to-show-an-alert-when-the-user-taps-on-the-list-row-in-swiftui
    @State var selectedItem = MLangBlogPost()
    var body: some View {
        VStack {
            SearchBar(text: $vm.postFilter, placeholder: "Filter") { _ in }
            List {
                ForEach(vm.arrPostsFiltered, id: \.ID) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.TITLE)
                                .font(.title)
                                .foregroundColor(Color.color2)
                        }
                        Spacer()
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .onTapGesture {
                                selectedItem = item
                                showContent()
                            }
                    }
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        AppDelegate.speak(string: item.TITLE)
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
        .refreshable {
            await vm.reloadPosts()
        }
        .alert(Text("Language Blog Post"), isPresented: $showItemMore, actions: {
            Button("Edit") {
                showDetail.toggle()
            }
            Button("Show Content") {
                showContent()
            }
        }, message: {
            Text(selectedItem.TITLE)
        })
        .navigationDestination(for: MLangBlogPost.self) { item in
            let index = vm.arrPostsFiltered.firstIndex(of: item)!
            let (start, end) = getPreferredRangeFromArray(index: index, length: vm.arrPostsFiltered.count, preferredLength: 50)
            LangBlogPostsContentView(navPath: $navPath, vm: LangBlogPostsContentViewModel(settings: vmSettings, vmGroups: vm, arrPosts: Array(vm.arrPostsFiltered[start ..< end]), selectedPostIndex: index))
        }
        .sheet(isPresented: $showDetail) {
            LangBlogPostsDetailView(item: selectedItem, showDetail: $showDetail)
        }
        .navigationTitle("Language Blog Posts (List)")
    }

    private func showContent() {
        vm.selectedPost = selectedItem
        navPath.append(selectedItem)
    }
}
