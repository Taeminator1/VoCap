//
//  ViewModifierExtension.swift
//  VoCap
//
//  Created by 윤태민 on 1/5/21.
//

import SwiftUI

// MARK: - HomeView
struct HomeListModifier: ViewModifier {
    var verticalPadding: CGFloat = -1.0             // 가장 상단에 Saperator 가리기 위해
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .listRowInsets(EdgeInsets())
            .background(Color(UIColor.systemBackground))
            .padding(.vertical, verticalPadding)
    }
}


// MARK: - NoteRow
struct NoteRowModifier: ViewModifier {
    let colorIndex: Int
    let height: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(height: height)
            .background(myColor.colors[colorIndex])
            .cornerRadius(10)
            .padding(.all)
    }
}

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


// MARK: - NoteDetail
struct NoteDetailListModifier: ViewModifier {
    var verticalPadding: CGFloat = -1.0
    
    func body(content: Content) -> some View {
        content
            .padding()                              // Seperator 가리기 위해
            .modifier(HomeListModifier(verticalPadding: verticalPadding))
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
