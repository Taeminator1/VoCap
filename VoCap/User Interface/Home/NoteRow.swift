//
//  NoteRow.swift
//  VoCap
//
//  Created by 윤태민 on 12/7/20.
//

import SwiftUI

enum rowType: Int {
    case AddNoteRow = -1
}

struct NoteRow: View {
    var title: String?
    var colorIndex: Int16 = 0
    var totalNumber: Int16 = 0
    var memorizedNumber: Int16 = 0
    
    @Binding var hideNoteDetailsNumber: Bool
    
    var body: some View {
        VStack() {
            HStack() {
                Image(systemName: "square").imageScale(.large)
                Text(title!)
                    .font(.largeTitle)
                
                Spacer()
            }
            Spacer()
            
            HStack() {
                Spacer()
                
                Text("외운 목록 수: \(memorizedNumber) / \(totalNumber)")
                    .font(.body)
                    .modifier(VisibilityStyle(hidden: $hideNoteDetailsNumber))
            }
        }
        .padding()
        .modifier(NoteRowModifier(colorIndex: Int(colorIndex), height: 83))
    }
}

struct AddNoteRow: View {
    var body: some View {
        VStack() {
            HStack() {
                Spacer()
                
                Image(systemName: "plus.circle").imageScale(.large)
                Text("Add Note")
                    .font(.largeTitle)

                Spacer()
            }
        }
        .padding()
        .modifier(AddNoteRowModifier(colorIndex: rowType.AddNoteRow.rawValue, height: 83))
    }
}


// MARK: - Preivew


struct NoteRow_Previews: PreviewProvider {
    static var previews: some View {
        NoteRow(title: "Example 1", hideNoteDetailsNumber: .constant(false))
            .previewLayout(.sizeThatFits)
        
        AddNoteRow()
            .previewLayout(.sizeThatFits)
    }
}
