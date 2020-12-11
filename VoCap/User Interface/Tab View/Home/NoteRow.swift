//
//  NoteRow.swift
//  VoCap
//
//  Created by 윤태민 on 12/7/20.
//

import SwiftUI

struct NoteRow: View {
    let note: Note
    
    var body: some View {
        VStack() {
            HStack() {
                Image(systemName: "square").imageScale(.large)
                Text(note.title)
                    .font(.system(size: 40))
                    .fontWeight(.medium)
                    
                Spacer()
            }
            .padding([.top, .leading, .trailing])
            
            Spacer()
            
            HStack() {
                Spacer()
                Text("외운 목록 수: \(note.memorizedNumber) / \(note.totalNumber)")
            }
            .padding([.leading, .bottom, .trailing])
        }
        .frame(height: 100)
        .background(myColor.colors[note.colorIndex])
        .cornerRadius(10)
        .shadow(color: .blue, radius: 1, x: 2, y: 2)
        .padding(.vertical, 5.0)
    }
}

struct AddNoteRow: View {
    let addNote: AddNote
    
    var body: some View {
        VStack() {
            HStack() {
                Spacer()
                
                Image(systemName: "plus.circle").imageScale(.large)
                Text(addNote.title)
                    .font(.title)
                    .fontWeight(.medium)
                    
                Spacer()
            }
        }
        .frame(height: 100)
        .background(addNote.color)
        .cornerRadius(10)
        .shadow(color: .blue, radius: 1, x: 2, y: 2)
        .padding(.vertical, 5.0)
    }
}

struct NoteRow_Previews: PreviewProvider {
    static var previews: some View {
        NoteRow(note: Note())
            .previewLayout(.sizeThatFits)
        
        AddNoteRow(addNote: AddNote())
            .previewLayout(.sizeThatFits)
    }
}