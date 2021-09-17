//
//  NoteDetailTextStyle.swift
//  VoCap
//
//  Created by 윤태민 on 9/17/21.
//

// Modifier for Text in NoteDetailView.

import SwiftUI

struct NoteDetailTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.body)
            .minimumScaleFactor(0.8)
            .lineLimit(2)
    }
}

extension View {
    func noteDetailTextStyle() -> some View {
        self
            .modifier(NoteDetailTextStyle())
    }
}

