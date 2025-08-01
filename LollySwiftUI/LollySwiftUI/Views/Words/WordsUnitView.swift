//
//  WordsUnitView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2022/12/15.
//

import SwiftUI

struct WordsUnitView: View {
    @Binding var navPath: NavigationPath
    @StateObject var vm = WordsUnitViewModel(inTextbook: true)
    @Environment(\.editMode) var editMode
    var isEditing: Bool { editMode?.wrappedValue.isEditing == true }
    @State var showDetailEdit = false
    @State var showDetailAdd = false
    @State var showBatchEdit = false
    @State var showItemMore = false
    @State var showListMore = false
    @State var showDelete = false
    @State var selectedItem = MUnitWord()
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
                ForEach(vm.arrWords, id: \.ID) { item in
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
                            selectedItem = item
                            showDetailEdit.toggle()
                        } else {
                            AppDelegate.speak(string: item.WORD)
                        }
                    }
                    .swipeActions(allowsFullSwipe: false) {
                        Button("More") {
                            selectedItem = item
                            showItemMore.toggle()
                        }
                        Button("Delete", role: .destructive) {
                            selectedItem = item
                            showDelete.toggle()
                        }
                    }
                }
                .onDelete { IndexSet in

                }
                .onMove { source, destination in
                    
                }
            }
            .task {
                await vm.reload()
            }
            .refreshable {
                await vm.reload()
            }
            .alert(Text("delete"), isPresented: $showDelete, actions: {
                Button("No", role: .cancel) {}
                Button("Yes", role: .destructive) {
                    
                }
            }, message: {
                Text(selectedItem.WORDNOTE)
            })
            .alert(Text("Word"), isPresented: $showItemMore, actions: {
                itemMoreActions
            }, message: {
                Text(selectedItem.WORDNOTE)
            })
            .navigationDestination(for: MUnitWord.self) { item in
                WordsDictView(vm: WordsDictViewModel(arrWords: vm.arrWords.map(\.WORD), selectedWordIndex: vm.arrWords.firstIndex(of: item)!))
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
                listMoreActions
            }, message: {
                Text("More")
            })
            .sheet(isPresented: $showDetailEdit) {
                WordsUnitDetailView(vmEdit: WordsUnitDetailViewModel(vm: vm, item: selectedItem, phraseid: 0), showDetail: $showDetailEdit)
            }
            .sheet(isPresented: $showDetailAdd) {
                WordsUnitDetailView(vmEdit: WordsUnitDetailViewModel(vm: vm, item: vm.newUnitWord(), phraseid: 0), showDetail: $showDetailAdd)
            }
            .sheet(isPresented: $showBatchEdit) {
                WordsUnitBatchEditView(vm: vm, showBatch: $showBatchEdit)
            }
        }
    }
    
    var itemMoreActions: some View {
        Group {
            Button("Delete", role: .destructive) {
                showDelete.toggle()
            }
            Button("Edit") {
                showDetailEdit.toggle()
            }
            Button("Get Note") {
                Task {
                    await vm.getNote(item: selectedItem)
                }
            }
            Button("Clear Note") {
                Task {
                    await vm.clearNote(item: selectedItem)
                }
            }
            Button("Copy Word") {
                iOSApi.copyText(selectedItem.WORD)
            }
            Button("Google Word") {
                iOSApi.googleString(selectedItem.WORD)
            }
            Button("Online Dictionary") {
                let itemDict = vmSettings.arrDictsReference.first { $0.DICTNAME == vmSettings.selectedDictReference.DICTNAME }!
                let url = itemDict.urlString(word: selectedItem.WORD, arrAutoCorrect: vmSettings.arrAutoCorrect)
                UIApplication.shared.open(URL(string: url)!)
            }
        }
    }
    
    var listMoreActions: some View {
        Group {
            Button("Add") {
                showDetailAdd.toggle()
            }
            Button("Get All Notes") {
                getNotes(ifEmpty: false)
            }
            Button("Get Notes If Empty") {
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
        }
    }

    func getNotes(ifEmpty: Bool) {
        Task {
            await vm.getNotes(ifEmpty: ifEmpty, oneComplete: { _ in }, allComplete: {})
        }
    }
}
