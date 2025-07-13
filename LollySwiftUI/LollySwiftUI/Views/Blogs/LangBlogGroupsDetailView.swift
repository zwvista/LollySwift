//
//  LangBlogGroupsDetailView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2022/12/24.
//

import SwiftUI

struct LangBlogGroupsDetailView: View {
    @State var item: MLangBlogGroup
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
                    Text("GROUP:")
                    Spacer()
                    TextField("GROUP", text: $item.GROUPNAME)
                }
            }
            .navigationBarItems(leading: Button("Cancel", role: .cancel) {
                showDetail.toggle()
            })
        }
    }
}
