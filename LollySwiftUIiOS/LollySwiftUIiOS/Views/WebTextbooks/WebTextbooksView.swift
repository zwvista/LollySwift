//
//  WebTextbooksView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/15.
//

import SwiftUI

struct WebTextbooksView: View {
    @Binding var navPath: NavigationPath
    @StateObject var vm = WebTextbooksViewModel(settings: vmSettings, needCopy: false) {}
    @State var showDetailEdit = false
    @State var showDetailAdd = false
    @State var showItemMore = false
    @State var showDelete = false
    // https://stackoverflow.com/questions/59235879/how-to-show-an-alert-when-the-user-taps-on-the-list-row-in-swiftui
    @State var currentItem = MWebTextbook()
    var body: some View {
        VStack {
//            HStack(spacing: 0) {
//                SearchBar(text: $vm.textFilter, placeholder: "Filter") { _ in }
//                Picker("", selection: $vm.scopeFilter) {
//                    ForEach(SettingsViewModel.arrScopeWebTextbookFilters, id: \.self) { s in
//                        Text(s)
//                    }
//                }
//                .background(Color.color2)
//                .tint(.white)
//            }
//            List {
//                ForEach(vm.arrWebTextbooksFiltered, id: \.ID) { item in
//                    HStack {
//                        VStack(alignment: .leading) {
//                            Text(item.PATTERN)
//                                .font(.title)
//                                .foregroundColor(Color.color2)
//                            Text(item.TAGS)
//                                .foregroundColor(Color.color3)
//                        }
//                        Spacer()
//                        Image(systemName: "info.circle")
//                            .foregroundColor(.blue)
//                            .onTapGesture {
//                                currentItem = item
//                                navPath.append(BrowseViewTag())
//                            }
//                    }
//                    .contentShape(Rectangle())
//                    .frame(maxWidth: .infinity)
//                    .onTapGesture {
//                        AppDelegate.speak(string: item.PATTERN)
//                    }
//                    .swipeActions(allowsFullSwipe: false) {
//                        Button("More") {
//                            currentItem = item
//                            showItemMore.toggle()
//                        }
//                        Button("Delete", role: .destructive) {
//                            currentItem = item
//                            showDelete.toggle()
//                        }
//                    }
//                }
//            }
//            .refreshable {
//                await vm.reload()
//            }
//            .alert(Text("delete"), isPresented: $showDelete, actions: {
//                Button("No", role: .cancel) {}
//                Button("Yes", role: .destructive) {
//
//                }
//            }, message: {
//                Text(currentItem.PATTERN)
//            })
//            .alert(Text("WebTextbook"), isPresented: $showItemMore, actions: {
//                Button("Delete", role: .destructive) {
//                }
//                Button("Edit") {
//                    showDetailEdit.toggle()
//                }
//                Button("Browse Web Page") {
//                    navPath.append(BrowseViewTag())
//                }
//            }, message: {
//                Text(currentItem.PATTERN)
//            })
//            .navigationDestination(for: BrowseViewTag.self) { _ in
//                WebTextbooksWebPageView(item: currentItem)
//            }
//            .toolbar {
//                ToolbarItemGroup {
//                    Button("Add") {
//                        showDetailAdd.toggle()
//                    }
//                }
//            }
//            .sheet(isPresented: $showDetailEdit) {
//                WebTextbooksDetailView(vmEdit: WebTextbooksDetailViewModel(vm: vm, item: currentItem), showDetail: $showDetailEdit)
//            }
//            .sheet(isPresented: $showDetailAdd) {
//                WebTextbooksDetailView(vmEdit: WebTextbooksDetailViewModel(vm: vm, item: vm.newWebTextbook()), showDetail: $showDetailAdd)
//            }
        }
    }

    struct BrowseViewTag: Hashable {}
}
