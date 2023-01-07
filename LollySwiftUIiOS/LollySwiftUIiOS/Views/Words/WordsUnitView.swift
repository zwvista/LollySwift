//
//  WordsUnitView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/15.
//

import SwiftUI

struct WordsUnitView: View {
    @Binding var navPath: NavigationPath
    @StateObject var vm = WordsUnitViewModel(settings: vmSettings, inTextbook: true, needCopy: false) {}
    @Environment(\.editMode) var editMode
    var isEditing: Bool { editMode?.wrappedValue.isEditing == true }
    @State var showDetailEdit = false
    @State var showDetailAdd = false
    @State var showBatchEdit = false
    @State var showItemMore = false
    @State var showListMore = false
    @State var showDelete = false
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
                        WordsUnitDetailView(vmEdit: WordsUnitDetailViewModel(vm: vm, item: item, phraseid: 0, complete: {}), showDetail: $showDetailEdit)
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
            .toolbar {
                ToolbarItemGroup {
                    EditButton()
                    Button("More") {
                        showListMore.toggle()
                    }
                }
            }
            .alert(Text("Words"), isPresented: $showListMore, actions: {
                Button("Add") {
                    showDetailAdd.toggle()
                }
                Button("Retrieve All Notes") {
                    getNotes(ifEmpty: false)
                }
                Button("Retrieve Notes If Empty") {
                    getNotes(ifEmpty: true)
                }
                Button("Clear All Notes") {
                    Task {
                        await vm.clearNotes(ifEmpty: false) { _ in }
                    }
                }
                Button("Clear Notes If Empty") {
                    Task {
                        await vm.clearNotes(ifEmpty: true) { _ in }
                    }
                }
                Button("Batch Edit") {
                    showBatchEdit.toggle()
                }
                Button("Cancel", role: .cancel) {}
            }, message: {
                Text("More")
            })
            .sheet(isPresented: $showDetailAdd) {
                WordsUnitDetailView(vmEdit: WordsUnitDetailViewModel(vm: vm, item: vm.newUnitWord(), phraseid: 0, complete: {}), showDetail: $showDetailAdd)
            }
            .sheet(isPresented: $showBatchEdit) {
                WordsUnitBatchEditView(vm: vm, showBatch: $showBatchEdit)
            }
        }
    }

    func getNotes(ifEmpty: Bool) {
        Task {
            await vm.getNotes(ifEmpty: ifEmpty, oneComplete: { _ in }, allComplete: {})
        }
    }
}
