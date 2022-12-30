//
//  PatternWebPagesBrowseView.swift
//  LollySwiftUIiOS
//
//  Created by 趙偉 on 2022/12/30.
//

import SwiftUI

struct PatternWebPagesBrowseView: View {
    @ObservedObject var vm: PatternsWebPagesViewModel
    @Binding var showBrowse: Bool
    var body: some View {
        VStack {
            Picker("", selection: $vm.currentWebPageIndex) {
                ForEach(vm.arrWebPages.indices, id: \.self) {
                    Text(vm.arrWebPages[$0].TITLE)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .background(Color.color3)
            .tint(.white)
            .pickerStyle(MenuPickerStyle())
        }
    }
}

//struct PatternWebPagesBrowseView_Previews: PreviewProvider {
//    static var previews: some View {
//        PatternWebPagesBrowseView()
//    }
//}
