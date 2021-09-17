//
//  AddNoteRowStyle.swift
//  VoCap
//
//  Created by 윤태민 on 9/16/21.
//

//  Modifier for row style for "Add Note" Button in HomeView.

import SwiftUI

struct AddNoteRowStyle: ViewModifier {
    let height: CGFloat
    let radius: CGFloat = 10.0
    
    func body(content: Content) -> some View {
        content
            .frame(height: height)
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(Color.systemGray, style: StrokeStyle(lineWidth: 2, dash: [10]))
                    .padding(.all, 1)
            )
            .padding()
    }
}

extension View {
    func addNoteRowStyle(_ height: CGFloat = 83) -> some View {
        self
            .modifier(AddNoteRowStyle(height: 83))
    }
}
