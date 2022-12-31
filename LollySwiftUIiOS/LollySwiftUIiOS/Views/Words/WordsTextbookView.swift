//
//  WordsTextbookView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/30.
//

import SwiftUI

struct WordsTextbookView: View {
    @Binding var navPath: NavigationPath
    @StateObject var vm = WordsUnitViewModel(settings: vmSettings, inTextbook: false, needCopy: false) {}
    @Environment(\.editMode) var editMode
    var isEditing: Bool { editMode?.wrappedValue.isEditing == true }
    @State var showDetailEdit = false
    @State var showItemMore = false
    @State var showDelete = false
    var body: some View {
        VStack {
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
                        VStack {
                            Text(item.UNITSTR)
                            Text(item.PARTSTR)
                            Text("\(item.SEQNUM)")
                        }
                        .font(.caption)
                        .foregroundColor(Color.color1)
                        VStack(alignment: .leading) {
                            Text(item.WORD)
                                .font(.title)
                                .foregroundColor(Color.color2)
                            Text(item.NOTE)
                                .foregroundColor(Color.color3)
                        }
                        Spacer()
                        if !isEditing {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .onTapGesture {
                                    navPath.append(item)
                                }
                        }
                    }
                    // https://stackoverflow.com/questions/65100077/swiftui-how-can-you-use-on-tap-gesture-for-entire-item-in-a-foreach-loop
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        if isEditing {
                            showDetailEdit.toggle()
                        } else {
                            AppDelegate.speak(string: item.WORD)
                        }
                    }
                    .sheet(isPresented: $showDetailEdit) {
                        WordsTextbookDetailView(vmEdit: WordsUnitDetailViewModel(vm: vm, item: item, phraseid: 0, complete: {}), showDetail: $showDetailEdit)
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
                        Text(item.WORDNOTE)
                    })
                    .alert(Text("Word"), isPresented: $showItemMore, actions: {
                        Button("Delete", role: .destructive) {
                            showDelete.toggle()
                        }
                        Button("Edit") {
                            showDetailEdit.toggle()
                        }
                        Button("Retrieve Note") {
                            Task {
                                await self.vm.getNote(item: item)
                            }
                        }
                        Button("Clear Note") {
                            Task {
                                await self.vm.clearNote(item: item)
                            }
                        }
                        Button("Copy Word") {
                            iOSApi.copyText(item.WORD)
                        }
                        Button("Google Word") {
                            iOSApi.googleString(item.WORD)
                        }
                        Button("Online Dictionary") {
                            let itemDict = vmSettings.arrDictsReference.first { $0.DICTNAME == vmSettings.selectedDictReference.DICTNAME }!
                            let url = itemDict.urlString(word: item.WORD, arrAutoCorrect: vmSettings.arrAutoCorrect)
                            UIApplication.shared.open(URL(string: url)!)
                        }
                    }, message: {
                        Text(item.WORDNOTE)
                    })
                }
                .onDelete { IndexSet in

                }
            }
            .navigationDestination(for: MUnitWord.self) { item in
                WordsDictView(vm: WordsDictViewModel(settings: vmSettings, needCopy: false, arrWords: vm.arrWordsFiltered.map(\.WORD), currentWordIndex: vm.arrWordsFiltered.firstIndex(of: item)!) {})
            }
        }
    }
}
