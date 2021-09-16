//
//  ViewModifierExtension.swift
//  VoCap
//
//  Created by 윤태민 on 1/5/21.
//

import SwiftUI


struct AddNoteRowModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    let colorIndex: Int
    let height: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(height: height)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.systemGray, style: StrokeStyle(lineWidth: 2, dash: [10]))
                    .padding(.all, 1)
            )
            .padding(.all)
    }
    
    func noteRowColor() -> Color {
        return colorScheme == .dark ? Color.white : Color.black
    }
}

struct VisibilityStyle: ViewModifier {
   
   @Binding var hidden: Bool
    
   func body(content: Content) -> some View {
      Group {
         if hidden {
            content.hidden()
         } else {
            content
         }
      }
   }
}


struct NoteDetailCellModifier: ViewModifier {

    var bodyColor: Color = Color.clear
    var strokeColor: Color
    let cornerRadius: CGFloat = 5
    let width: CGFloat = .infinity
    let height: CGFloat = 45
    var lineWidth: CGFloat = 0.0
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .frame(idealWidth: width, maxWidth: width, idealHeight: height, maxHeight: height, alignment: .leading)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(strokeColor, lineWidth: lineWidth)
            )
            .background(bodyColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

struct NoteDetailCellModifier2: ViewModifier {
    
    var bodyColor: Color = Color.clear
    var strokeColor: Color
    
    func body(content: Content) -> some View {
        content
            .font(.body)
            .minimumScaleFactor(0.8)
            .lineLimit(2)
            .modifier(NoteDetailCellModifier(bodyColor: bodyColor, strokeColor: strokeColor))
    }
}


// MARK: - Tip
struct TipModifier: ViewModifier {
    let order: Int
    
    func body(content: Content) -> some View {
        content
            .frame(width: TipInfo.tips[order].viewSize.width, height: TipInfo.tips[order].viewSize.height)
            .cornerRadius(12)
    }
}
