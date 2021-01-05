//
//  NoteDetail.swift
//  VoCap
//
//  Created by 윤태민 on 12/9/20.
//

import SwiftUI

struct NoteDetail: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var note: Note          // @State할 때는, 값이 바뀌어도 갱신이 안 됨,
    
    @State var id: Int = -1
    @State var term: String = ""
    @State var definition: String = ""
    @State var isMemorized: Bool = false
    
    @State var tmpNoteDetails: [TmpNoteDetail] = []
    
    @State private var isEditMode: EditMode = .inactive
    
    var body: some View {
        List {
            ForEach(tmpNoteDetails) { tmpNoteDetail in
                HStack {
                    Text(tmpNoteDetail.term)
                        .modifier(NoteDetailListModifier())
                        
                    Text(tmpNoteDetail.definition)
                        .modifier(NoteDetailListModifier())
                    
                    Button(action: {
                        if isEditMode == .inactive  {
                            changeMemorizedState(id: tmpNoteDetail.id)
                        }
                        else {
                            id = tmpNoteDetail.id
                            editNoteDetail(id: tmpNoteDetail.id)
                        }
                    }) {
                        if tmpNoteDetail.isMemorized == true    { Image(systemName: "square.fill").imageScale(.large) }
                        else                                    { Image(systemName: "square").imageScale(.large) }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .listRowInsets(EdgeInsets())
                .padding(5)
            }
            .onDelete(perform: deleteItems)
        }
        .onAppear() {
            for i in 0..<note.term.count {
                tmpNoteDetails.append(TmpNoteDetail(id: i, term: note.term[i], definition: note.definition[i], isMemorized: note.isMemorized[i]))
            }
        }
        .navigationBarTitle("\(note.title!)", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) { EditButton() }
            
            ToolbarItem(placement: .bottomBar) { bottom1Item }
            ToolbarItem(placement: .bottomBar) { Spacer() }
            ToolbarItem(placement: .bottomBar) { bottom2Item }
        }
        .environment(\.editMode, self.$isEditMode)          // 해당 위치에 없으면 isEditMode 안 먹힘
        
        HStack {
            TextField("term", text: $term)
                .modifier(NoteDetailEditorModifier())
            
            TextField("definition", text: $definition)
                .modifier(NoteDetailEditorModifier())
            
            Button(action: { add() }) {
                Text("Add")
            }
            .disabled(term == "" || definition == "" ? true : false)
        }
        .padding()
    }
}

// MARK: - Tool Bar Items
extension NoteDetail {
    var bottom1Item: some View {
        Button(action: {print("1") }) {
            Image(systemName: "1.square.fill")
        }
    }
    
    var bottom2Item: some View {
        Button(action: {print("2") }) {
            Image(systemName: "2.square.fill")
        }
    }
}


extension NoteDetail {
    func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    func add() {
        if isEditMode == .inactive {
            note.term.append(term)
            note.definition.append(definition)
            note.isMemorized.append(false)
            
            id = note.term.count - 1
            tmpNoteDetails.append(TmpNoteDetail(id: id, term: term, definition: definition, isMemorized: isMemorized))
            note.totalNumber = Int16(id + 1)
            saveContext()
        }
        else {
            note.term[id] = term
            note.definition[id] = definition
            
            tmpNoteDetails[id] = TmpNoteDetail(id: id, term: term, definition: definition, isMemorized: isMemorized)
            saveContext()
        }
        term = ""
        definition = ""
    }
    
    func deleteItems(at offsets: IndexSet) {
        note.totalNumber -= 1
        if tmpNoteDetails[offsets.map({$0}).first!].isMemorized == true {
            note.memorizedNumber -= 1
        }

        note.term.remove(atOffsets: offsets)
        note.definition.remove(atOffsets: offsets)
        note.isMemorized.remove(atOffsets: offsets)
        
        tmpNoteDetails.remove(atOffsets: offsets)
        saveContext()
        
        for i in 0..<note.term.count {
            tmpNoteDetails[i].id = i
        }
    }
    
    func changeMemorizedState(id: Int) {
        if tmpNoteDetails[id].isMemorized == true {
            tmpNoteDetails[id].isMemorized = false
            note.memorizedNumber -= 1
        }
        else {
            tmpNoteDetails[id].isMemorized = true
            note.memorizedNumber += 1
        }
        note.isMemorized[id] = tmpNoteDetails[id].isMemorized
        saveContext()
    }
    
    func editNoteDetail(id: Int) {
        term = tmpNoteDetails[id].term
        definition = tmpNoteDetails[id].definition
    }
    
}

//struct NoteDetail_Previews: PreviewProvider {
//
//    static var previews: some View {
//        NoteDetail(note: Note())
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//            .previewDevice("iPhone XR")
//    }
//}





