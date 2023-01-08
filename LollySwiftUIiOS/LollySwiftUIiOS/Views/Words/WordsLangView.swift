//
//  WordsLangView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/15.
//

import SwiftUI

struct WordsLangView: View {
    @Binding var navPath: NavigationPath
    @StateObject var vm = WordsLangViewModel(settings: vmSettings, needCopy: false) {}
    @State var showDetail = false
    @State var showDetailEdit = false
    @State var showDetailAdd = false
    @State var showDict = false
    @State var showItemMore = false
    @State var showDelete = false
    @State var currentItem = MLangWord()
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                SearchBar(text: $vm.textFilter, placeholder: "Filter") { _ in }
                Picker("", selection: $vm.scopeFilter) {
                    ForEach(SettingsViewModel.arrScopeWordFilters, id: \.self) { s in
                        Text(s)
                    }
                }
                .background(Color.color2)
                .tint(.white)
            }
            List {
                ForEach(vm.arrWordsFiltered, id: \.ID) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.WORD)
                                .font(.title)
                                .foregroundColor(Color.color2)
                            Text(item.NOTE)
                                .foregroundColor(Color.color3)
                        }
                        Spacer()
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .onTapGesture {
                                showDict.toggle()
                            }
                    }
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        AppDelegate.speak(string: item.WORD)
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
                Text(currentItem.WORDNOTE)
            })
            .alert(Text("Word"), isPresented: $showItemMore, actions: {
                Button("Delete", role: .destructive) {
                    showDelete.toggle()
                }
                Button("Edit") {
                    showDetailEdit.toggle()
                }
                Button("Copy Word") {
                    iOSApi.copyText(currentItem.WORD)
                }
                Button("Google Word") {
                    iOSApi.googleString(currentItem.WORD)
                }
                Button("Online Dictionary") {
                    let itemDict = vmSettings.arrDictsReference.first { $0.DICTNAME == vmSettings.selectedDictReference.DICTNAME }!
                    let url = itemDict.urlString(word: currentItem.WORD, arrAutoCorrect: vmSettings.arrAutoCorrect)
                    UIApplication.shared.open(URL(string: url)!)
                }
            }, message: {
                Text(currentItem.WORDNOTE)
            })
            .toolbar {
                ToolbarItemGroup {
                    Button("Add") {
                        showDetailAdd.toggle()
                    }
                }
            }
            .sheet(isPresented: $showDetailEdit) {
                WordsLangDetailView(vmEdit: WordsLangDetailViewModel(vm: vm, item: currentItem, complete: {}), showDetail: $showDetailEdit)
            }
            .sheet(isPresented: $showDetailAdd) {
                WordsLangDetailView(vmEdit: WordsLangDetailViewModel(vm: vm, item: vm.newLangWord(), complete: {}), showDetail: $showDetailAdd)
            }
        }
    }
}
