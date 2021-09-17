//
//  NoteDetailTextFieldStyle.swift
//  VoCap
//
//  Created by 윤태민 on 9/17/21.
//

// Modifier for TextField in NoteDetailView.

import SwiftUI

struct NoteDetailTextFieldStyle: ViewModifier {
    var bodyColor: Color = Color.clear
    var strokeColor: Color
    let radius: CGFloat = 5.0
    let width: CGFloat = .infinity
    let height: CGFloat = 45
    var lineWidth: CGFloat = 0.0
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .frame(idealWidth: width, maxWidth: width, idealHeight: height, maxHeight: height, alignment: .leading)
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(strokeColor, lineWidth: lineWidth)
            )
            .background(bodyColor)
            .clipShape(RoundedRectangle(cornerRadius: radius))
    }
}

extension View {
    func noteDetailTextFieldStyle(bodyColor: Color, strokeColor: Color, lineWidth: CGFloat = 0.0) -> some View {
        self
            .modifier(NoteDetailTextFieldStyle(bodyColor: bodyColor, strokeColor: strokeColor, lineWidth: lineWidth))
    }
}
