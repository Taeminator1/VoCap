//
//  NoteButton.swift
//  VoCap
//
//  Created by 윤태민 on 7/30/21.
//

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
                if isEditMode == .inactive || isEditMode == .transient {    // When Edit Button has been not pressed
                    id = note.id                         // 왜 noteRowSelection에 !붙일 때랑 안 붙일 때 다르지?
                }
                else {                                                      // When Edit Button has been pressed by user
                    order = Int(note.order)
                    isPresented = true
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
    
    func countTrues(_ arr: [Bool]) -> Int {
        var result: Int = 0
        for i in 0..<arr.count {
            if arr[i] { result += 1 }
        }
        return result
    }
}
