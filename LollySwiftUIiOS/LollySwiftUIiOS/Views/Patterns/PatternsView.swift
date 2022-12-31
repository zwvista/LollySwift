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
                                navPath.append(item)
                            }
                    }
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        AppDelegate.speak(string: item.PATTERN)
                    }
                    .sheet(isPresented: $showDetailEdit) {
                        PatternsDetailView(vmEdit: PatternsDetailViewModel(vm: vm, item: item), showDetail: $showDetailEdit)
                    }
                    .swipeActions(allowsFullSwipe: false) {
                        Button("More") {
                            showItemMore.toggle()
                        }
                        Button("Delete", role: .destructive) {
                            showDelete.toggle()
                        }
                    }
                    .alert(Text("delete"), isPresented: $showDelete, actions: {
                        Button("No", role: .cancel) {}
                        Button("Yes", role: .destructive) {
                            
                        }
                    }, message: {
                        Text(item.PATTERN)
                    })
                    .alert(Text("Pattern"), isPresented: $showItemMore, actions: {
                        Button("Delete", role: .destructive) {
                        }
                        Button("Edit") {
                            showDetailEdit.toggle()
                        }
                        Button("Browse Web Pages") {
                        }
                        Button("Edit Web Pages") {
                        }
                        Button("Copy Pattern") {
                            iOSApi.copyText(item.PATTERN)
                        }
                        Button("Google Pattern") {
                            iOSApi.googleString(item.PATTERN)
                        }
                    }, message: {
                        Text(item.PATTERN)
                    })
                }
            }
            .navigationDestination(for: MPattern.self) { item in
                PatternWebPagesBrowseView(vm: PatternsWebPagesViewModel(settings: vmSettings, needCopy: false, item: item))
            }
            .toolbar {
                ToolbarItemGroup {
                    Button("Add") {
                        showDetailAdd.toggle()
                    }
                }
            }
            .sheet(isPresented: $showDetailAdd) {
                PatternsDetailView(vmEdit: PatternsDetailViewModel(vm: vm, item: vm.newPattern()), showDetail: $showDetailAdd)
            }
        }
    }
}
