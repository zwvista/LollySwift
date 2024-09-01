//
//  OnlineTextbooksView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2022/12/15.
//

import SwiftUI

struct OnlineTextbooksView: View {
    @Binding var navPath: NavigationPath
    @StateObject var vm = OnlineTextbooksViewModel(settings: vmSettings, needCopy: false) {}
    @State var showDetail = false
    @State var showItemMore = false
    // https://stackoverflow.com/questions/59235879/how-to-show-an-alert-when-the-user-taps-on-the-list-row-in-swiftui
    @State var currentItem = MOnlineTextbook()
    var body: some View {
        VStack {
            Spacer()
            Picker("", selection: $vm.stringOnlineTextbookFilter) {
                ForEach(vmSettings.arrOnlineTextbookFilters.map(\.label), id: \.self) { s in
                    Text(s)
                }
            }
            .modifier(PickerModifier(backgroundColor: Color.color3))
            List {
                ForEach(vm.arrOnlineTextbooksFiltered, id: \.ID) { item in
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
                    }
                }
            }
            .refreshable {
                await vm.reload()
            }
            .alert(Text("OnlineTextbook"), isPresented: $showItemMore, actions: {
                Button("Edit") {
                    showDetail.toggle()
                }
                Button("Browse Web Page") {
                    navPath.append(BrowseViewTag())
                }
            }, message: {
                Text(currentItem.TITLE)
            })
            .navigationDestination(for: BrowseViewTag.self) { _ in
                OnlineTextbooksWebPageView(item: currentItem)
            }
            .sheet(isPresented: $showDetail) {
                OnlineTextbooksDetailView(item: currentItem, showDetail: $showDetail)
            }
        }
    }

    struct BrowseViewTag: Hashable {}
}
