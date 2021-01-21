//
//  NoteDetailView.swift
//  VoCap
//
//  Created by 윤태민 on 12/9/20.
//

import SwiftUI

struct NoteDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var note: Note          // @State할 때는, 값이 바뀌어도 갱신이 안 됨,
    
    @State var order: Int = -1
    @State var term: String = ""
    @State var definition: String = ""
    @State var isMemorized: Bool = false
    
    @State var tmpNoteDetails: [NoteDetail] = []
    
    @State var editMode: EditMode = .inactive
    @State var selection = Set<UUID>()
    
    @State var isTermsHiding: Bool = false
    @State var isDefsHiding: Bool = false
    @State var isShuffled: Bool = false
    
    @State var isTermScaled: Bool = false
    @State var isDefScaled: Bool = false
    @State var isScaledArray: [Bool] = []
    
    var body: some View {
        List(selection: $selection) {
            ForEach(tmpNoteDetails) { noteDetail in
                noteDetailRow(noteDetail)
            }
            .onDelete(perform: deleteItems)
            .deleteDisabled(isShuffled)             // Shuffle 상태일 때 delete 못하게 함
        }
        .animation(.default)                    // 해당 자리에 있어야 함
        .onAppear() { copyNoteDetails() }
        .navigationBarTitle("\(note.title!)", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) { editButton.disabled(isShuffled) }
            ToolbarItem(placement: .bottomBar) { if editMode == .inactive { showingTermsButton } }
            ToolbarItem(placement: .bottomBar) { Spacer() }
            ToolbarItem(placement: .bottomBar) { if editMode == .inactive { shuffleButton } }
            ToolbarItem(placement: .bottomBar) { Spacer() }
            ToolbarItem(placement: .bottomBar) {
                if editMode == .inactive { showingDefsButton }
                else { deleteButton }
            }
        }
        .environment(\.editMode, self.$editMode)          // 해당 위치에 없으면 editMode 안 먹힘
        
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

extension NoteDetailView {
    func noteDetailRow(_ noteDetail: NoteDetail) -> some View {
        HStack {
            ZStack(alignment: .leading) {
                noteDetailText(noteDetail.term, strokeColor: .blue)
                noteDetailScreen(noteDetail.order, strokeColor: .blue, isScreen: isTermsHiding, anchor: .leading)
            }
                
            ZStack(alignment: .trailing) {
                noteDetailText(noteDetail.definition, strokeColor: .green)
                noteDetailScreen(noteDetail.order, strokeColor: .green, isScreen: isDefsHiding, anchor: .trailing)
            }
            
            Button(action: {
                if editMode == .inactive { changeMemorizedState(id: noteDetail.id) }
                else { editNoteDetail(index: noteDetail.order) }         // 선택 하면 해당 row 편집
            }) {
//                        if editMode == .inactive {
                    noteDetail.isMemorized == true ? Image(systemName: "square.fill") : Image(systemName: "square")
//                        }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .listRowInsets(EdgeInsets())
        .padding(5)
    }
    
    func noteDetailText(_ text: String, strokeColor: Color) -> some View {
        Text(text)
            .padding(.horizontal)
            .modifier(NoteDetailListModifier(strokeColor: strokeColor))
    }
    
    func noteDetailScreen(_ order: Int, strokeColor: Color, isScreen: Bool, anchor: UnitPoint) -> some View {
        Rectangle()
            .foregroundColor(strokeColor)
            .frame(width: 5)
            .scaleEffect(x: isScreen && !isScaledArray[order] ? 35 : 1, y: 1, anchor: anchor)
            .animation(.default)
            .onTapGesture{}                 // Scroll 되게 하려면 필요(해당 자리에)
            .modifier(CustomGestureModifier(isPressed: $isScaledArray[order], f: { }))
    }
}

// MARK: - Tool Bar Items
extension NoteDetailView {
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
private extension NoteDetailView {
    func copyNoteDetails() {
        for i in 0..<note.term.count {
            tmpNoteDetails.append(NoteDetail(order: i, term: note.term[i], definition: note.definition[i], isMemorized: note.isMemorized[i]))
            
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
extension NoteDetailView {
    func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func add() {
        if editMode == .inactive {
            note.term.append(term)
            note.definition.append(definition)
            note.isMemorized.append(false)
            
            tmpNoteDetails.append(NoteDetail(order: note.term.count - 1, term: term, definition: definition, isMemorized: isMemorized))
            note.totalNumber = Int16(order + 1)
            saveContext()
            
            isScaledArray.append(Bool(true))
        }
        else {
            note.term[order] = term
            note.definition[order] = definition

            tmpNoteDetails[order] = NoteDetail(order: order, term: term, definition: definition, isMemorized: isMemorized)
            saveContext()
        }
        term = ""
        definition = ""
    }
    
    private var editButton: some View {
        if editMode == .inactive {
            return Button(action: {
                self.editMode = .active
                self.selection = Set<UUID>()
            }) {
                Text("Edit")
            }
        }
        else {
            return Button(action: {
                self.editMode = .inactive
                self.selection = Set<UUID>()
            }) {
                Text("Done")
            }
        }
    }
    
    private var deleteButton: some View {
        Button(action: {
            for id in selection {
                if let index = tmpNoteDetails.lastIndex(where: { $0.id == id })  {
                    note.term.remove(at: index)
                    note.definition.remove(at: index)
                    note.isMemorized.remove(at: index)
                    
                    tmpNoteDetails.remove(at: index)
                    isScaledArray.remove(at: index)
                }
            }
            saveContext()
            
            for i in 0..<note.term.count {
                tmpNoteDetails[i].order = i
            }
        }) {
            Text("Delete")
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        let index = offsets.map({$0}).first!
        
        note.totalNumber -= 1
        if tmpNoteDetails[index].isMemorized == true {
            note.memorizedNumber -= 1
        }

        note.term.remove(atOffsets: offsets)
        note.definition.remove(atOffsets: offsets)
        note.isMemorized.remove(atOffsets: offsets)
        
//        note.term.remove(at: tmpNoteDetails[index].order)
//        note.definition.remove(at: tmpNoteDetails[index].order)
//        note.isMemorized.remove(at: tmpNoteDetails[index].order)

        tmpNoteDetails.remove(atOffsets: offsets)
        isScaledArray.remove(atOffsets: offsets)
        
        saveContext()
        
        // shuffle 상태에서 삭제하면 해당 구문이 return 못하게 함(shuffle 상태에서는 delete 못하게 함)
        for i in 0..<note.term.count {
            tmpNoteDetails[i].order = i
        }
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


//struct NoteDetailView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        NoteDetailView(note: Note())
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//            .previewDevice("iPhone XR")
//    }
//}

