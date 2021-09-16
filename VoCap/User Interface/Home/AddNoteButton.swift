//
//  AddNoteButton.swift
//  VoCap
//
//  Created by 윤태민 on 7/30/21.
//

//  Button to add a note.

import SwiftUI

struct AddNoteButton: View {
    @Binding var isPresent: Bool
    @Binding var isEditMode: EditMode
    
    var body: some View {
        Button(action: { isPresent = true }) { AddNoteRow() }
            .disabled(isEditMode == .inactive ? false : true)
            .listRowStyle()
            .buttonStyle(BorderlessButtonStyle())
    }
}

enum RowType: Int {
    case AddNoteRow = -1
}

struct AddNoteRow: View {
    var body: some View {
        VStack() {
            HStack() {
                Spacer()
                Image(systemName: "plus.circle").imageScale(.large)
                Text("Add Note")
                    .font(.title)
                Spacer()
            }
        }
        .padding()
        .addNoteRowStyle()
    }
}

// MARK: - Preivew
struct AddNoteRow_Previews: PreviewProvider {
    static var previews: some View {
        AddNoteRow()
            .previewLayout(.sizeThatFits)
    }
}
