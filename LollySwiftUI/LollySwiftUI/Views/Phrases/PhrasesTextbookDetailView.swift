//
//  PhrasesTextbookDetailView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2022/12/30.
//

import SwiftUI

struct PhrasesTextbookDetailView: View {
    @StateObject var vmEdit: PhrasesUnitDetailViewModel
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
                    Text("TEXTBOOK:")
                    Spacer()
                    Text(vmEdit.itemEdit.TEXTBOOKNAME)
                }
                HStack {
                    Text("UNIT:")
                    Spacer()
                    Picker("", selection: $vmEdit.itemEdit.indexUNIT) {
                        ForEach(vmSettings.arrUnits.indices, id: \.self) {
                            Text(vmSettings.arrUnits[$0].label)
                        }
                    }
                }
                HStack {
                    Text("PART:")
                    Spacer()
                    Picker("", selection: $vmEdit.itemEdit.indexPART) {
                        ForEach(vmSettings.arrParts.indices, id: \.self) {
                            Text(vmSettings.arrParts[$0].label)
                        }
                    }
                }
                HStack {
                    Text("SEQNUM:")
                    Spacer()
                    TextField("SEQNUM", text: $vmEdit.itemEdit.SEQNUM)
                }
                HStack{
                    Text("PHRASEID:")
                    Spacer()
                    Text(vmEdit.itemEdit.PHRASEID)
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
            .navigationTitle("Phrases in Textbook (Edit)")
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
