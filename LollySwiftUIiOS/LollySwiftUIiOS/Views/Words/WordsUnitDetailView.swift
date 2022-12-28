//
//  WordsUnitDetailView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/18.
//

import SwiftUI

struct WordsUnitDetailView: View {
    @ObservedObject var vmEdit: WordsUnitDetailViewModel
    // https://stackoverflow.com/questions/56517400/swiftui-dismiss-modal
    @Binding var showDetail: Bool
    var body: some View {
        // https://stackoverflow.com/questions/59702997/can-a-modal-sheet-have-a-navigation-bar-in-swiftui
        NavigationView {
            Form {
                HStack {
                    Text("ID:")
                    Spacer()
                    Text(vmEdit.itemEdit.ID)
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
            }
            .navigationBarItems(leading: Button("Cancel") {
                showDetail.toggle()
            }, trailing: Button("Done") {
                Task{
                    await vmEdit.onOK()
                    showDetail.toggle()
                }
            })
        }
    }
}

//struct WordsUnitDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        WordsUnitDetailView()
//    }
//}
