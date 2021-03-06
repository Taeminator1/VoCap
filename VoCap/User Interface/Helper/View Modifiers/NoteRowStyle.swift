//
//  NoteRowStyle.swift
//  VoCap
//
//  Created by 윤태민 on 9/16/21.
//

//  Modifier for row style for Note in HomeView.

import SwiftUI

struct NoteRowStyle: ViewModifier {
    let colorIndex: Int
    let height: CGFloat
    let radius: CGFloat = 10.0

    func body(content: Content) -> some View {
        content
            .padding()
            .frame(height: height)
            .background(Pallet.colors[colorIndex].value)
            .cornerRadius(radius)
            .padding()
    }
}

extension View {
    func noteRowStyle(_ colorIndex: Int, _ height: CGFloat = 83) -> some View {
        self
            .modifier(NoteRowStyle(colorIndex: colorIndex, height: height))
    }
}
