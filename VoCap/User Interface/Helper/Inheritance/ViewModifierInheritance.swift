//
//  ViewModifierExtension.swift
//  VoCap
//
//  Created by 윤태민 on 1/5/21.
//

import SwiftUI

// MARK: - HomeView
struct HomeViewNoteRowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .listRowInsets(EdgeInsets())
            .background(Color(UIColor.systemBackground))
    }
}


// MARK: - NoteRow
struct XxNoteRowModifier: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    let colorIndex: Int
    
    func body(content: Content) -> some View {
        content
            .frame(height: 100)
            .background(noteRowColor())
            .cornerRadius(10)
            .shadow(color: .blue, radius: 1, x: 2, y: 2)
            .padding(.all)
    }
    
    func noteRowColor() -> Color {
        if colorIndex == RowType.AddNoteRow.rawValue {       // Add Note Row
            return colorScheme == .dark ? Color.white : Color.black
//            return colorScheme == .dark ? Color.black : Color.white
        }
        else {                      // Note Row
            return myColor.colors[colorIndex]
        }
    }
}

struct NoteRowModifier: ViewModifier {
    let colorIndex: Int
    let height: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(height: height)
            .background(myColor.colors[colorIndex])
            .cornerRadius(10)
            .shadow(color: .blue, radius: 1, x: 2, y: 2)
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
                    .stroke(noteRowColor(), style: StrokeStyle(lineWidth: 2, dash: [10]))
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

    var strokeColor: Color
    let cornerRadius: CGFloat = 5
    
    func body(content: Content) -> some View {
        content
            .frame(idealWidth: .infinity, idealHeight: 45, maxHeight: 45, alignment: .leading)
            .frame(maxWidth: .infinity, maxHeight: 45, alignment: .leading)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(strokeColor, lineWidth: 2)
            )
            .background(Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
struct NoteDetailEditorModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .autocapitalization(.none)
    }
}

