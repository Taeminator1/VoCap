//
//  NoteButton.swift
//  VoCap
//
//  Created by 윤태민 on 7/30/21.
//

//  Button to present the MakeNoteView to edit note.
//  Button to enter the note:
//  - Link with NoteDetailView

import SwiftUI

struct NoteButton: View {
    @Binding var isEditMode: EditMode
    
    @Binding var order: Int?
    @Binding var isPresented: Bool
    
    @State private var id: UUID?                // For navigation link.
    @Binding var tipControls: [TipControl]
    
    @Binding var hideNumber: Bool
    let note: Note
    
    var body: some View {
        if note.title != nil {
            HStack {
                Button(action: {
                    switch(isEditMode) {
                    case .active:       // For MakeNoteView.
                        order = Int(note.order)
                        isPresented = true
                    default:            // For NavigationLink
                        id = note.id
                    }
                }) {
                    VStack() {
                        NoteRow(title: note.title!, colorIndex: note.colorIndex, totalNumber: Int16(note.term.count), memorizedNumber: Int16(countTrues(note.isMemorized)), hideNoteDetailsNumber: $hideNumber)
                    }
                }
                
                NavigationLink(destination: NoteDetailView(note: note, tipControls: $tipControls), tag: note.id!, selection: $id) { EmptyView() }
                .frame(width: 0).hidden()
            }
            .modifier(HomeListModifier())
            .buttonStyle(PlainButtonStyle())            // .active 상태 일 때 버튼 눌릴 수 있도록 함
        }
    }
    
    // Count memorized item in note.
    func countTrues(_ arr: [Bool]) -> Int {
        return arr.compactMap { $0 ? $0 : nil }.count
    }
}

struct NoteRow: View {
    var title: String?
    var colorIndex: Int16 = 0
    var totalNumber: Int16 = 0
    var memorizedNumber: Int16 = 0
    
    @Binding var hideNoteDetailsNumber: Bool
    
    var body: some View {
        VStack() {
            Spacer()
            HStack() {
                (totalNumber != 0 && totalNumber == memorizedNumber) ? Image(systemName: "checkmark.circle.fill") : Image(systemName: "circle")
                Text(title!)
                    .font(.title)
                Spacer()
            }
            Spacer()
            
            HStack() {
                Spacer()
                Text("Number of Items: \(memorizedNumber) / \(totalNumber)")
                    .font(.body)
                    .modifier(VisibilityStyle(hidden: $hideNoteDetailsNumber))
            }
        }
        .padding()
        .modifier(NoteRowModifier(colorIndex: Int(colorIndex), height: 83))
    }
}

// MARK: - Preivew
struct NoteRow_Previews: PreviewProvider {
    static var previews: some View {
        NoteRow(title: "Example 1", hideNoteDetailsNumber: .constant(false))
            .previewLayout(.sizeThatFits)
    }
}
