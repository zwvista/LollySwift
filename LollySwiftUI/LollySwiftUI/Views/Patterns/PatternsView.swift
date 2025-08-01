//
//  PatternsView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2022/12/15.
//

import SwiftUI

struct PatternsView: View {
    @Binding var navPath: NavigationPath
    @StateObject var vm = PatternsViewModel()
    @State var showDetail = false
    @State var showItemMore = false
    // https://stackoverflow.com/questions/59235879/how-to-show-an-alert-when-the-user-taps-on-the-list-row-in-swiftui
    @State var selectedItem = MPattern()
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
                ForEach(vm.arrPatterns, id: \.ID) { item in
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
                                selectedItem = item
                                navPath.append(selectedItem)
                            }
                    }
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        AppDelegate.speak(string: item.PATTERN)
                    }
                    .swipeActions(allowsFullSwipe: false) {
                        Button("More") {
                            selectedItem = item
                            showItemMore.toggle()
                        }
                    }
                }
            }
            .refreshable {
                await vm.reload()
            }
            .alert(Text("Pattern"), isPresented: $showItemMore, actions: {
                Button("Edit") {
                    showDetail.toggle()
                }
                Button("Browse Web Page") {
                    navPath.append(selectedItem)
                }
                Button("Copy Pattern") {
                    iOSApi.copyText(selectedItem.PATTERN)
                }
                Button("Google Pattern") {
                    iOSApi.googleString(selectedItem.PATTERN)
                }
            }, message: {
                Text(selectedItem.PATTERN)
            })
            .navigationDestination(for: MPattern.self) { item in
                let index = vm.arrPatterns.firstIndex(of: item)!
                let (start, end) = getPreferredRangeFromArray(index: index, length: vm.arrPatterns.count, preferredLength: 50)
                PatternsWebPageView(vm: PatternsWebPageViewModel(arrPatterns: Array(vm.arrPatterns[start ..< end]), selectedPatternIndex: index))
            }
            .sheet(isPresented: $showDetail) {
                PatternsDetailView(item: selectedItem, showDetail: $showDetail)
            }
        }
    }
}
