//
//  PatternsWebPagesDetailView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/30.
//

import SwiftUI

struct PatternsWebPagesDetailView: View {
    @ObservedObject var vmEdit: PatternsWebPagesDetailViewModel
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
                    Text("PATTERNID:")
                    Spacer()
                    Text(vmEdit.itemEdit.PATTERNID)
                }
                HStack {
                    Text("PATTERN:")
                    Spacer()
                    Text(vmEdit.itemEdit.PATTERN)
                }
                HStack {
                    Text("SEQNUM:")
                    Spacer()
                    TextField("SEQNUM", text: $vmEdit.itemEdit.SEQNUM)
                }
                HStack{
                    Text("WEBPAGEID:")
                    Spacer()
                    Text(vmEdit.itemEdit.WEBPAGEID)
                }
                HStack {
                    Text("TITLE:")
                    Spacer()
                    TextField("", text: $vmEdit.itemEdit.TITLE)
                }
                HStack {
                    Text("URL:")
                    Spacer()
                    TextField("", text: $vmEdit.itemEdit.URL)
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
