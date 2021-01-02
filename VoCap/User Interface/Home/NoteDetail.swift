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
    
    let cornerRadius: CGFloat = 5
    
    @ViewBuilder
    var body: some View {
        List {
            ForEach(tmpNoteDetails) { tmpNoteDetail in
                HStack {
                    Text(tmpNoteDetail.term)
                        .frame(maxWidth: .infinity, maxHeight: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                        .background(Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        
                    
                    Text(tmpNoteDetail.definition)
                        .frame(maxWidth: .infinity, maxHeight: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                        .background(Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    
                    Button(action: {
                        if isEditMode == .inactive  { changeMemorizedState(id: tmpNoteDetail.id) }
                        else                        {
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
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            
            ToolbarItem(placement: .bottomBar) {
                Button(action: {print("1") }) {
                    Image(systemName: "1.square.fill")
                }
            }
            
            ToolbarItem(placement: .bottomBar) { Spacer() }
            
            ToolbarItem(placement: .bottomBar) {
                Button(action: {print("2") }) {
                    Image(systemName: "2.square.fill")
                }
            }
        }
        .environment(\.editMode, self.$isEditMode)          // 해당 위치에 없으면 isEditMode 안 먹힘
        
        HStack {
            TextField("term", text: $term)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            TextField("definition", text: $definition)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            Button(action: { add() }) {
                Text("Add")
            }
            .disabled(term == "" || definition == "" ? true : false)
        }
        .padding()
    }
}

struct TmpNoteDetail: Identifiable {
    var id: Int = -1
    var term: String = ""
    var definition: String = ""
    var isMemorized: Bool = false
}

extension NoteDetail {
    func save() {
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
            save()
        }
        else {
            note.term[id] = term
            note.definition[id] = definition
            
            tmpNoteDetails[id] = TmpNoteDetail(id: id, term: term, definition: definition, isMemorized: isMemorized)
            save()
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
        
        save()
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
        save()
    }
    
    func editNoteDetail(id: Int) {
        term = tmpNoteDetails[id].term
        definition = tmpNoteDetails[id].definition
    }
    
}

//struct NoteDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        NoteDetail(title: "sample")
//    }
//}


