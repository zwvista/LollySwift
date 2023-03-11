//
//  PatternsDetailView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/24.
//

import SwiftUI

struct PatternsDetailView: View {
    @State var item: MPattern
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
                    Text("PATTERN:")
                    Spacer()
                    TextField("PATTERN", text: $item.PATTERN)
                }
                HStack {
                    Text("TAGS:")
                    Spacer()
                    TextField("TAGS", text: $item.TAGS)
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
