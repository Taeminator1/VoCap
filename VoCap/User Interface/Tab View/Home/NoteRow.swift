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
        .background(note.color)
        .cornerRadius(10)
        .shadow(color: .blue, radius: 1, x: 2, y: 2)
        .padding([.top, .leading, .trailing])
    }
}

struct AddNoteRow: View {
    let note: Note
    
    var body: some View {
        VStack() {
            HStack() {
                Spacer()
                
                Image(systemName: "plus.circle").imageScale(.large)
                Text(note.title)
                    .font(.title)
                    .fontWeight(.medium)
                    
                Spacer()
            }
        }
        .frame(height: 100)
        .background(note.color)
        .cornerRadius(10)
        .shadow(color: .blue, radius: 1, x: 2, y: 2)
        .padding([.top, .leading, .trailing])
    }
}

struct NoteRow_Previews: PreviewProvider {
    static var previews: some View {
        NoteRow(note: Note(title: "Architecture", color: Color.yellow, memorizedNumber: 5, totalNumber: 121))
            .previewLayout(.sizeThatFits)
        
        AddNoteRow(note: Note())
            .previewLayout(.sizeThatFits)
    }
}
