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
    
    @State var order: Int = -1
    @State var term: String = ""
    @State var definition: String = ""
    @State var isMemorized: Bool = false
    
    @State var tmpNoteDetails: [TmpNoteDetail] = []
    
    @State private var isEditMode: EditMode = .inactive
    
    @State private var isTermsHiding: Bool = false
    @State private var isDefsHiding: Bool = false
    @State private var isShuffled: Bool = false
    
    @State var isTermScaled: Bool = false
    @State var isDefScaled: Bool = false
    @State var isScaledArray: [Bool] = []
    
    var body: some View {
        List {
            ForEach(tmpNoteDetails) { noteDetail in
                HStack {
                    ZStack(alignment: .leading) {
                        Text(noteDetail.term)
                            .padding(.horizontal)
                            .modifier(NoteDetailListModifier(strokeColor: Color.blue))
                        
                        Rectangle()
                            .foregroundColor(.blue)
                            .frame(width: 5)
                            .scaleEffect(x: isTermScaled && !isScaledArray[noteDetail.order] ? 35 : 1, y: 1, anchor: .leading)
                            .animation(.default)
                            .onTapGesture{}                 // Scroll 되게 하려면 필요(해당 자리에)
                            .modifier(CustomGestureModifier(isPressed: $isScaledArray[noteDetail.order], f: { }))
                    }
                        
                    ZStack(alignment: .trailing) {
                        Text(noteDetail.definition)
                            .padding(.horizontal)
                            .modifier(NoteDetailListModifier(strokeColor: Color.green))
                        
                        Rectangle()
                            .foregroundColor(.green)
                            .frame(width: 5)
                            .scaleEffect(x: isDefScaled && !isScaledArray[noteDetail.order] ? 35 : 1, y: 1, anchor: .trailing)
                            .animation(.default)
                            .onTapGesture{}                 // Scroll 되게 하려면 필요(해당 자리에)
                            .modifier(CustomGestureModifier(isPressed: $isScaledArray[noteDetail.order], f: { }))
                    }
                    
                    Button(action: {
                        if isEditMode == .inactive  { changeMemorizedState(id: noteDetail.id) }
                        else                        { editNoteDetail(index: noteDetail.order) }
                    }) {
                        noteDetail.isMemorized == true ? Image(systemName: "square.fill") : Image(systemName: "square")
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                .listRowInsets(EdgeInsets())
                .padding(5)
            }
            .onDelete(perform: deleteItems)
            .deleteDisabled(isShuffled)             // Shuffle 상태일 때 delete 못하게 함
        }
        .animation(.default)                    // 해당 자리에 있어야 함
        .onAppear() {
            copyNoteDetails()
        }
        .navigationBarTitle("\(note.title!)", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) { EditButton().disabled(isShuffled) }
            
            ToolbarItem(placement: .bottomBar) { showingTermsButton }
            ToolbarItem(placement: .bottomBar) { Spacer() }
            ToolbarItem(placement: .bottomBar) { shuffleButton }
            ToolbarItem(placement: .bottomBar) { Spacer() }
            ToolbarItem(placement: .bottomBar) { showingDefsButton }
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
        .disabled(isShuffled)
        .padding()
    }
}

// MARK: - Tool Bar Items
extension NoteDetail {
    var showingTermsButton: some View {
        Button(action: {
                if isDefsHiding == true {
                    isDefsHiding.toggle()
                    isDefScaled.toggle()
                }
                
                isTermsHiding.toggle()
                isTermScaled.toggle() }) {
            isTermsHiding == true ? Image(systemName: "arrow.left") : Image(systemName: "arrow.right")
        }
    }
    
    var shuffleButton: some View {
        Button(action: { shuffleButtonAction() }) {
            isShuffled == true ? Image(systemName: "return") : Image(systemName: "shuffle")
        }
    }
    
    var showingDefsButton: some View {
        Button(action: {
                if isTermsHiding == true {
                    isTermsHiding.toggle()
                    isTermScaled.toggle()
                }
                
                isDefsHiding.toggle()
                isDefScaled.toggle() }) {
            isDefsHiding == true ? Image(systemName: "arrow.right") : Image(systemName: "arrow.left")
        }
    }
}


// MARK: - Other Functions
private extension NoteDetail {
    func copyNoteDetails() {
        for i in 0..<note.term.count {
            tmpNoteDetails.append(TmpNoteDetail(order: i, term: note.term[i], definition: note.definition[i], isMemorized: note.isMemorized[i]))
            isScaledArray.append(Bool(false))
        }
    }
    
    func shuffleButtonAction() -> Void {
        isShuffled.toggle()
        
        if isShuffled == true {
            tmpNoteDetails.shuffle()
        }
        else {
            tmpNoteDetails = tmpNoteDetails.sorted(by: { $0.order < $1.order })
        }
    }
}


// MARK: - Modify NoteDetails
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
            
            order = note.term.count - 1
            tmpNoteDetails.append(TmpNoteDetail(order: order, term: term, definition: definition, isMemorized: isMemorized))
            note.totalNumber = Int16(order + 1)
            saveContext()
            
            isScaledArray.append(Bool(true))
        }
        else {
            note.term[order] = term
            note.definition[order] = definition

            tmpNoteDetails.append(TmpNoteDetail(order: order, term: term, definition: definition, isMemorized: isMemorized))
            saveContext()
        }
        term = ""
        definition = ""
    }
    
    func deleteItems(at offsets: IndexSet) {
        let index = offsets.map({$0}).first!
        
        note.totalNumber -= 1
        if tmpNoteDetails[index].isMemorized == true {
            note.memorizedNumber -= 1
        }

//        note.term.remove(atOffsets: offsets)
//        note.definition.remove(atOffsets: offsets)
//        note.isMemorized.remove(atOffsets: offsets)
        
        note.term.remove(at: tmpNoteDetails[index].order)
        note.definition.remove(at: tmpNoteDetails[index].order)
        note.isMemorized.remove(at: tmpNoteDetails[index].order)

        tmpNoteDetails.remove(atOffsets: offsets)
        
        saveContext()
        
        // shuffle 상태에서 삭제하면 해당 구문이 return 못하게 함(shuffle 상태에서는 delete 못하게 함)
        for i in 0..<note.term.count {
            tmpNoteDetails[i].order = i
        }
        isScaledArray.remove(at: tmpNoteDetails[index].order)
    }
    
    func changeMemorizedState(id: UUID) {
        if let index = tmpNoteDetails.firstIndex(where: { $0.id == id }) {
            if tmpNoteDetails[index].isMemorized == true {
                tmpNoteDetails[index].isMemorized = false
                note.memorizedNumber -= 1
            }
            else {
                tmpNoteDetails[index].isMemorized = true
                note.memorizedNumber += 1
            }
            
            note.isMemorized[tmpNoteDetails[index].order] = tmpNoteDetails[index].isMemorized
            saveContext()
        }
    }
    
    func editNoteDetail(index: Int) {
        order = index
        term = tmpNoteDetails[index].term
        definition = tmpNoteDetails[index].definition
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





