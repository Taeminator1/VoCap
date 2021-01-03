//
//  NoteRow.swift
//  VoCap
//
//  Created by 윤태민 on 12/7/20.
//

import SwiftUI

struct NoteRow: View {
    var title: String?
    var colorIndex: Int16 = 0
    var totalNumber: Int16 = 0
    var memorizedNumber: Int16 = 0
    
    var body: some View {
        VStack() {
            HStack() {
                Image(systemName: "square").imageScale(.large)
                Text(title!)
                    .font(.system(size: 40))
                    .fontWeight(.medium)
                    
                Spacer()
            }
            .padding([.top, .leading, .trailing])
            
            Spacer()
            
            HStack() {
                Spacer()
                Text("외운 목록 수: \(memorizedNumber) / \(totalNumber)")
            }
            .padding([.leading, .bottom, .trailing])
        }
        .modifier(NoteRowModifier(colorIndex: Int(colorIndex)))
    }
}

struct AddNoteRow: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack() {
            HStack() {
                Spacer()
                
                Image(systemName: "plus.circle").imageScale(.large)
                Text("Add Note")
                    .font(.title)
                    .fontWeight(.medium)
                    
                Spacer()
            }
        }
        .modifier(NoteRowModifier(colorIndex: -1))
    }
}


// MARK: - Preivew
struct NoteRow_Previews: PreviewProvider {
    static var previews: some View {
        NoteRow(title: "sample")
            .previewLayout(.sizeThatFits)
        
        AddNoteRow()
            .previewLayout(.sizeThatFits)
    }
}


// MARK: - Modifier
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
