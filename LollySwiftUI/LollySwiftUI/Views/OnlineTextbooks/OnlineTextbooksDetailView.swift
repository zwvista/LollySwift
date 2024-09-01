//
//  OnlineTextbooksDetailView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2022/12/24.
//

import SwiftUI

struct OnlineTextbooksDetailView: View {
    @State var item: MOnlineTextbook
    @Binding var showDetail: Bool
    var body: some View {
        NavigationView {
            Form {
                HStack {
                    Text("ID:")
                    Spacer()
                    Text("\(item.ID)")
                }
                HStack {
                    Text("TEXTBOOK:")
                    Spacer()
                    Text(item.TEXTBOOKNAME)
                }
                HStack {
                    Text("UNIT:")
                    Spacer()
//                    TextField("UNIT", text: $item.UNIT, formatter: NumberFormatter())
                }
                HStack {
                    Text("TITLE:")
                    Spacer()
                    TextField("NOTE", text: $item.TITLE)
                }
                HStack {
                    Text("URL:")
                    Spacer()
                    TextField("NOTE", text: $item.URL)
                }
            }
            .navigationBarItems(leading: Button("Cancel", role: .cancel) {
                showDetail.toggle()
            })
        }
    }
}
