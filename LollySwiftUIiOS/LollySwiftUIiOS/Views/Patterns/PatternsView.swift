//
//  PatternsView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/15.
//

import SwiftUI

struct PatternsView: View {
    @Binding var navPath: NavigationPath
    @StateObject var vm = PatternsViewModel(settings: vmSettings, needCopy: false) {}
    @State var showDetailEdit = false
    @State var showDetailAdd = false
    @State var showItemMore = false
    @State var showDelete = false
    // https://stackoverflow.com/questions/59235879/how-to-show-an-alert-when-the-user-taps-on-the-list-row-in-swiftui
    @State var currentItem = MPattern()
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                SearchBar(text: $vm.textFilter, placeholder: "Filter") { _ in }
                Picker("", selection: $vm.scopeFilter) {
                    ForEach(SettingsViewModel.arrScopePatternFilters, id: \.self) { s in
                        Text(s)
                    }
                }
                .background(Color.color2)
                .tint(.white)
            }
            List {
                ForEach(vm.arrPatternsFiltered, id: \.ID) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.PATTERN)
                                .font(.title)
                                .foregroundColor(Color.color2)
                            Text(item.TAGS)
                                .foregroundColor(Color.color3)
                        }
                        Spacer()
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .onTapGesture {
                                vm.showBrowse = true
                                navPath.append(item)
                            }
                    }
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        AppDelegate.speak(string: item.PATTERN)
                    }
                    .swipeActions(allowsFullSwipe: false) {
                        Button("More") {
                            currentItem = item
                            showItemMore.toggle()
                        }
                        Button("Delete", role: .destructive) {
                            currentItem = item
                            showDelete.toggle()
                        }
                    }
                }
            }
            .refreshable {
                await vm.reload()
            }
            .alert(Text("delete"), isPresented: $showDelete, actions: {
                Button("No", role: .cancel) {}
                Button("Yes", role: .destructive) {

                }
            }, message: {
                Text(currentItem.PATTERN)
            })
            .alert(Text("Pattern"), isPresented: $showItemMore, actions: {
                Button("Delete", role: .destructive) {
                }
                Button("Edit") {
                    showDetailEdit.toggle()
                }
                Button("Browse Web Pages") {
                    vm.showBrowse = true
                    navPath.append(currentItem)
                }
                Button("Edit Web Pages") {
                    vm.showBrowse = false
                    navPath.append(currentItem)
                }
                Button("Copy Pattern") {
                    iOSApi.copyText(currentItem.PATTERN)
                }
                Button("Google Pattern") {
                    iOSApi.googleString(currentItem.PATTERN)
                }
            }, message: {
                Text(currentItem.PATTERN)
            })
            .navigationDestination(for: MPattern.self) { item in
                if vm.showBrowse {
                    PatternsWebPagesBrowseView(vm: PatternsWebPagesViewModel(settings: vmSettings, needCopy: false, item: item))
                } else {
                    PatternsWebPagesListView(vm: PatternsWebPagesViewModel(settings: vmSettings, needCopy: false, item: item))
                }
            }
           .toolbar {
                ToolbarItemGroup {
                    Button("Add") {
                        showDetailAdd.toggle()
                    }
                }
            }
            .sheet(isPresented: $showDetailEdit) {
                PatternsDetailView(vmEdit: PatternsDetailViewModel(vm: vm, item: currentItem), showDetail: $showDetailEdit)
            }
            .sheet(isPresented: $showDetailAdd) {
                PatternsDetailView(vmEdit: PatternsDetailViewModel(vm: vm, item: vm.newPattern()), showDetail: $showDetailAdd)
            }
        }
    }
}
