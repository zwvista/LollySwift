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
            Spacer()
            Picker("", selection: $vm.stringWebTextbookFilter) {
                ForEach(vmSettings.arrWebTextbookFilters.map(\.label), id: \.self) { s in
                    Text(s)
                }
            }
            .modifier(PickerModifier(backgroundColor: Color.color3))
            List {
                ForEach(vm.arrWebTextbooksFiltered, id: \.ID) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.TEXTBOOKNAME)
                                .font(.title)
                                .foregroundColor(Color.color2)
                            Text(item.TITLE)
                                .foregroundColor(Color.color3)
                        }
                        Spacer()
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .onTapGesture {
                                currentItem = item
                                navPath.append(BrowseViewTag())
                            }
                    }
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        AppDelegate.speak(string: item.TITLE)
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
            .alert(Text("WebTextbook"), isPresented: $showItemMore, actions: {
                Button("Delete", role: .destructive) {
                }
                Button("Edit") {
                    showDetailEdit.toggle()
                }
                Button("Browse Web Page") {
                    navPath.append(BrowseViewTag())
                }
            }, message: {
                Text(currentItem.TITLE)
            })
            .navigationDestination(for: BrowseViewTag.self) { _ in
                WebTextbooksWebPageView(item: currentItem)
            }
            .sheet(isPresented: $showDetailEdit) {
                WebTextbooksDetailView(item: currentItem, showDetail: $showDetailEdit)
            }
        }
    }

    struct BrowseViewTag: Hashable {}
}
