//
//  NoteButton.swift
//  VoCap
//
//  Created by 윤태민 on 7/30/21.
//

//  Button for note in HomeView

import SwiftUI

struct NoteButton: View {
    @Binding var isPresented: Bool
    @Binding var isEditMode: EditMode
    @Binding var id: UUID?
    @Binding var order: Int?
    
    @Binding var hideNumber: Bool
    @Binding var tipControls: [TipControl]
    
    let note: Note
    
    var body: some View {
        HStack {
            Button(action: {
                switch(isEditMode) {
                case .active:
                    order = Int(note.order)
                    isPresented = true
                default:
                    id = note.id
                }
            }) {
                VStack() {
                    NoteRow(title: note.title!, colorIndex: note.colorIndex, totalNumber: Int16(note.term.count), memorizedNumber: Int16(countTrues(note.isMemorized)), hideNoteDetailsNumber: $hideNumber)
                }
            }
            
            NavigationLink(destination: NoteDetailView(note: note, tipControls: $tipControls), tag: note.id!, selection: $id) {
                EmptyView()
            }
            .frame(width: 0).hidden()
        }
        .listModifier()
        .buttonStyle(PlainButtonStyle())            // .active 상태 일 때 버튼 눌릴 수 있도록 함
    }
    
    // Count memorized item in note.
    func countTrues(_ arr: [Bool]) -> Int {
        return arr.compactMap { $0 ? $0 : nil }.count
    }
}
