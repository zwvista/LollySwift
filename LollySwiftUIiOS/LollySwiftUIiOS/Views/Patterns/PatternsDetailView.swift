//
//  PatternsDetailView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/24.
//

import SwiftUI

struct PatternsDetailView: View {
    @ObservedObject var vmEdit: PatternsDetailViewModel
    @Binding var showDetail: Bool
    var body: some View {
        NavigationView {
            Form {
                HStack {
                    Text("ID:")
                    Spacer()
                    Text(vmEdit.itemEdit.ID)
                }
                HStack {
                    Text("PATTERN:")
                    Spacer()
                    TextField("PATTERN", text: $vmEdit.itemEdit.PATTERN)
                }
                HStack {
                    Text("NOTE:")
                    Spacer()
                    TextField("NOTE", text: $vmEdit.itemEdit.NOTE)
                }
                HStack {
                    Text("TAGS:")
                    Spacer()
                    TextField("TAGS", text: $vmEdit.itemEdit.TAGS)
                }
            }
            .navigationBarItems(leading: Button("Cancel", role: .cancel) {
                showDetail.toggle()
            }, trailing: Button("Done") {
                Task {
                    await vmEdit.onOK()
                    showDetail.toggle()
                }
            }.disabled(!vmEdit.isOKEnabled))
        }
    }
}
