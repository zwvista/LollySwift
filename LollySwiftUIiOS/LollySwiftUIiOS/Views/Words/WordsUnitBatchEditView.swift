//
//  WordsUnitBatchEditView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/29.
//

import SwiftUI

struct WordsUnitBatchEditView: View {
    @ObservedObject var vm: WordsUnitViewModel
    @Binding var showBatch: Bool
    var body: some View {
        Form {
            HStack {
                Text("UNIT:")
                Spacer()
//                Picker("", selection: $vmEdit.itemEdit.indexUNIT) {
//                    ForEach(vmSettings.arrUnits.indices, id: \.self) {
//                        Text(vmSettings.arrUnits[$0].label)
//                    }
//                }
            }
            HStack {
                Text("PART:")
                Spacer()
//                Picker("", selection: $vmEdit.itemEdit.indexPART) {
//                    ForEach(vmSettings.arrParts.indices, id: \.self) {
//                        Text(vmSettings.arrParts[$0].label)
//                    }
//                }
            }
            HStack {
                Text("SEQNUM:")
                Spacer()
//                TextField("SEQNUM", text: $vmEdit.itemEdit.SEQNUM)
            }
        }
        .navigationBarItems(leading: Button("Cancel", role: .cancel) {
            showBatch.toggle()
        }, trailing: Button("Done") {
        })
    }
}
