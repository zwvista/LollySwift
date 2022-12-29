//
//  WordsLangView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/15.
//

import SwiftUI

struct WordsLangView: View {
    @StateObject var vm = WordsLangViewModel(settings: vmSettings, needCopy: false) {}
    @Environment(\.editMode) var editMode
    var isEditing: Bool { editMode?.wrappedValue.isEditing == true }
    @State var showDetail = false
    @State var showDetailEdit = false
    @State var showDetailAdd = false
    @State var showBatchEdit = false
    @State var showDict = false
    @State var showItemMore = false
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
                                    showDict.toggle()
                                }
                        }
                    }
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        if isEditing {
                            showDetailEdit.toggle()
                        } else {
                            LollySwiftUIiOSApp.speak(string: item.WORD)
                        }
                    }
                    .sheet(isPresented: $showDetailEdit) {
                        WordsLangDetailView(vmEdit: WordsLangDetailViewModel(vm: vm, item: item, complete: {}), showDetail: $showDetailEdit)
                    }
                    .sheet(isPresented: $showDict) {
                        WordsDictView()
                    }
                    .swipeActions(allowsFullSwipe: false) {
                        Button("More") {
                            showItemMore.toggle()
                        }
                        Button("Delete") {
                            
                        }
                        .tint(Color.red)
                    }
                    .alert(Text("Word"), isPresented: $showItemMore, actions: {
                        Button("Delete") {
                        }
                        Button("Edit") {
                            showDetailEdit.toggle()
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
                        Button("Cancel") {}
                    }, message: {
                        Text(item.WORDNOTE)
                    })
                }
                .onDelete { IndexSet in

                }
            }
            .toolbar {
                ToolbarItemGroup {
                    EditButton()
                    Button("Add") {
                        showDetailAdd.toggle()
                    }
                }
            }
            .sheet(isPresented: $showDetailAdd) {
                WordsLangDetailView(vmEdit: WordsLangDetailViewModel(vm: vm, item: vm.newLangWord(), complete: {}), showDetail: $showDetailAdd)
            }
        }
    }
}

struct WordsLangView_Previews: PreviewProvider {
    static var previews: some View {
        WordsLangView()
    }
}
