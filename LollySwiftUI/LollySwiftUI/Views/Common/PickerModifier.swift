//
//  PickerModifier.swift
//  LollySwiftUI
//
//  Created by 趙偉 on 2022/12/31.
//

import SwiftUI

struct PickerModifier: ViewModifier {
    @State var backgroundColor: Color
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .tint(.white)
            .pickerStyle(MenuPickerStyle())
    }
}
