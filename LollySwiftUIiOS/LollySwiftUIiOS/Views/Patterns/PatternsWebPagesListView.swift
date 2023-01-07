//
//  PatternsWebPagesListView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/30.
//

import SwiftUI

struct PatternsWebPagesListView: View {
    @ObservedObject var vm: PatternsWebPagesViewModel
    @Environment(\.editMode) var editMode
    var isEditing: Bool { editMode?.wrappedValue.isEditing == true }
    @State var showDetailEdit = false
    @State var showDetailAdd = false
    @State var currentItem = MPatternWebPage()
    var body: some View {
        List {
            ForEach(vm.arrWebPages, id: \.ID) { item in
                HStack {
                    Text("\(item.SEQNUM)")
                        .foregroundColor(Color.color1)
                    VStack(alignment: .leading) {
                        Text(item.TITLE)
                            .foregroundColor(Color.color2)
                        Text(item.URL)
                            .font(.caption)
                            .foregroundColor(Color.color3)
                    }
                }
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    if isEditing {
                        currentItem = item
                        showDetailEdit.toggle()
                    } else {
                        AppDelegate.speak(string: item.TITLE)
                    }
                }
            }
        }
        .navigationTitle("Pattern Web Pages (Edit)")
        .onAppear {
            Task{
                await vm.getWebPages()
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
        .sheet(isPresented: $showDetailEdit) {
            PatternsWebPagesDetailView(vmEdit: PatternsWebPagesDetailViewModel(item: currentItem), showDetail: $showDetailEdit)
        }
        .sheet(isPresented: $showDetailAdd) {
            PatternsWebPagesDetailView(vmEdit: PatternsWebPagesDetailViewModel(item: vm.newPatternWebPage()), showDetail: $showDetailAdd)
        }
    }
}
