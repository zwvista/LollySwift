//
//  PatternsView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/15.
//

import SwiftUI

struct PatternsView: View {
    @StateObject var vm = PatternsViewModel(settings: vmSettings, needCopy: false) {}
    @Environment(\.editMode) var editMode
    @State var showDetail = false
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
                ForEach(vm.arrPatterns, id: \.ID) { row in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(row.PATTERN)
                                .font(.title)
                                .foregroundColor(Color.color2)
                            Text(row.TAGS)
                                .foregroundColor(Color.color3)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if editMode?.wrappedValue.isEditing == true {
                            showDetail = true
                        } else {
                            LollySwiftUIiOSApp.speak(string: row.PATTERN)
                        }
                    }
                    .sheet(isPresented: $showDetail) {
                        PatternsDetailView()
                    }
                }
            }
        }
    }
}

struct PatternsView_Previews: PreviewProvider {
    static var previews: some View {
        PatternsView()
    }
}
