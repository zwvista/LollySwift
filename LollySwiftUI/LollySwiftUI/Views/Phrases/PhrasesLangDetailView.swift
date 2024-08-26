//
//  PhrasesLangDetailView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2022/12/24.
//

import SwiftUI

struct PhrasesLangDetailView: View {
    @StateObject var vmEdit: PhrasesLangDetailViewModel
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
                    Text("PHRASE:")
                    Spacer()
                    TextField("", text: $vmEdit.itemEdit.PHRASE)
                }
                HStack {
                    Text("TRANSLATION:")
                    Spacer()
                    TextField("", text: $vmEdit.itemEdit.TRANSLATION)
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
