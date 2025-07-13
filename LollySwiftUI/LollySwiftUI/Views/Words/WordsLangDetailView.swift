//
//  WordsLangDetailView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2022/12/24.
//

import SwiftUI

struct WordsLangDetailView: View {
    @StateObject var vmEdit: WordsLangDetailViewModel
    @Binding var showDetail: Bool
    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    Text("ID:")
                    Spacer()
                    Text(vmEdit.itemEdit.ID)
                }
                HStack {
                    Text("WORD:")
                    Spacer()
                    TextField("", text: $vmEdit.itemEdit.WORD)
                }
                HStack {
                    Text("NOTE:")
                    Spacer()
                    TextField("", text: $vmEdit.itemEdit.NOTE)
                }
                HStack{
                    Text("FAMIID:")
                    Spacer()
                    Text(vmEdit.itemEdit.FAMIID)
                }
                HStack{
                    Text("ACCURACY:")
                    Spacer()
                    Text(vmEdit.itemEdit.ACCURACY)
                }
            }
            .navigationTitle("Words in Language (Edit)")
            .navigationBarTitleDisplayMode(.inline)
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
