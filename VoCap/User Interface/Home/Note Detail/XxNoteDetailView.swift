//
//  NoteDetailView.swift
//  VoCap
//
//  Created by 윤태민 on 1/15/21.
//

import SwiftUI

struct XxNoteDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
//    @ObservedObject var note: Note          // @State할 때는, 값이 바뀌어도 갱신이 안 됨      // For Real
    @State var note = Note_Previews()       // For Previews
    
//    @State var tmpNoteDetails: [NoteDetail] = []     // For Real
    @State var tmpNoteDetails: [NoteDetail] =
        [NoteDetail(term: "Term1Term1Term1Term1Term1Term1Term1Term1", definition: "Definition1", isMemorized: false),
         NoteDetail(term: "Term2", definition: "Definition2", isMemorized: true),
         NoteDetail(term: "Term3", definition: "Definition3", isMemorized: false),
         NoteDetail(term: "Term4", definition: "Definition4", isMemorized: false),
         NoteDetail(term: "Term5", definition: "Definition5", isMemorized: true)]    // For Previews
    
    @State var tmpNoteDetail = NoteDetail()
    
    @State private var isAddMode: Bool = false
    @State private var editMode: EditMode = .inactive
    @State private var selection = Set<UUID>()
    
    @State private var isTermsScreen: Bool = false
    @State private var isDefsScreen: Bool = false
    @State private var isShuffled: Bool = false
    
    @State var isGlancing: Bool = false
    @State var isGlancings: [Bool] = [true, false, true, true, true]
    
    var body: some View {
        NavigationView {                    // For Previews
            List(selection: $selection) {
                ForEach(tmpNoteDetails) { noteDetail in
                    NoteDetailItem(tmpNoteDetail: noteDetail, editMode: editMode)
                }
                
                if isAddMode {
                    HStack {
                        TextField("Term", text: $tmpNoteDetail.term)
                            .padding(.horizontal)
                            .modifier(NoteDetailListModifier(strokeColor: .blue))
                        
                        TextField("Difinition", text: $tmpNoteDetail.definition)
                            .padding(.horizontal)
                            .modifier(NoteDetailListModifier(strokeColor: .green))
                    }
                }
            }
            .animation(.default)                    // 해당 자리에 있어야 함
            .navigationBarTitle("\(note.title!)", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { addButton.disabled(editMode == .active || isShuffled) }
                ToolbarItem(placement: .navigationBarTrailing) { editButton.disabled(isAddMode || isShuffled) }
                
                ToolbarItem(placement: .bottomBar) { if editMode == .inactive && isAddMode == false { termsScreenButton } }
                ToolbarItem(placement: .bottomBar) { Spacer() }
                ToolbarItem(placement: .bottomBar) { shuffleButton }
                ToolbarItem(placement: .bottomBar) { Spacer() }
                ToolbarItem(placement: .bottomBar) { defsScreenButton }
            }
            .environment(\.editMode, self.$editMode)          // 해당 위치에 없으면 editMode 안 먹힘
        }                                   // For Previews
    }
}


// MARK: - Tool Bar Items
extension XxNoteDetailView {
    private var addButton: some View {
        Button(action: { }) { Text("Add") }
    }
    
    private var editButton: some View {
        Button(action: { }) { Text("Edit") }
    }
    
    private var deleteButton: some View {
        Button(action: { }) { Text("Delete") }
    }
    
    private var termsScreenButton: some View {
        Button(action: { }) {
            isTermsScreen == true ? Image(systemName: "arrow.left") : Image(systemName: "arrow.right")
        }
    }
    
    private var shuffleButton: some View {
        Button(action: { }) {
            isShuffled == true ? Image(systemName: "return") : Image(systemName: "shuffle")
        }
    }
    
    private var defsScreenButton: some View {
        Button(action: { }) {
            isDefsScreen == true ? Image(systemName: "arrow.right") : Image(systemName: "arrow.left")
        }
    }
}


// MARK: - Preivew
struct XxNoteDetailView_Previews: PreviewProvider {

    static var previews: some View {
//        XxNoteDetailView(note: Note())          // For Real
        XxNoteDetailView(note: Note_Previews())       // For Previews
    }
}

struct Note_Previews {
    var colorIndex: Int16 = Int16(0)
    var id: UUID = UUID()
    var isAutoCheck = false
    var isWidget = false
    var memo: String = "memo"
    var memorizedNumber: Int16 = Int16(0)
    var order: Int16 = 0
    var title: String? = "Example"
    var totalNumber: Int16 = Int16(100)
    
    var term: [String] = ["Term1", "Term2", "Term3", "Term4", "Term5"]
    var definition: [String] = ["Def1", "Def2", "Def3", "Def4", "Def5"]
    var isMemorized: [Bool] = [false, true, true, false, true]
}
