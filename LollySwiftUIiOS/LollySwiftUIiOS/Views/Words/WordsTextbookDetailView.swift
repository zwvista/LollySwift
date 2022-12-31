//
//  WordsTextbookDetailView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/30.
//

import SwiftUI

struct WordsTextbookDetailView: View {
    @ObservedObject var vmEdit: WordsUnitDetailViewModel
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
                    Text("WORDID:")
                    Spacer()
                    Text(vmEdit.itemEdit.WORDID)
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
            .navigationBarItems(leading: Button("Cancel", role: .cancel) {
                showDetail.toggle()
            }, trailing: Button("Done") {
                Task{
                    await vmEdit.onOK()
                    showDetail.toggle()
                }
            }.disabled(!vmEdit.isOKEnabled))
        }
    }
}
