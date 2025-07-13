//
//  LangBlogPostsDetailView.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2022/12/24.
//

import SwiftUI

struct LangBlogPostsDetailView: View {
    @State var item: MLangBlogPost
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
                    Text("TITLE:")
                    Spacer()
                    TextField("TITLE", text: $item.TITLE)
                }
            }
            .navigationBarItems(leading: Button("Cancel", role: .cancel) {
                showDetail.toggle()
            })
        }
    }
}
