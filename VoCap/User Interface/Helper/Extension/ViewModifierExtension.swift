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
struct NoteRowModifier: ViewModifier {
    
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
        if colorIndex == -1 {       // Add Note Row
            return colorScheme == .dark ? Color.white : Color.black
        }
        else {                      // Note Row
            return myColor.colors[colorIndex]
        }
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
            .frame(maxWidth: .infinity, maxHeight: 60, alignment: .leading)
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

