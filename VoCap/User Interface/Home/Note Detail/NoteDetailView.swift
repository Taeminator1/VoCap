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
    
    @State var tmpNoteDetails: [NoteDetail] = []
    
    @State var editMode: EditMode = .inactive
    @State var selection = Set<UUID>()
    
    @State var isTermsScreen: Bool = false
    @State var isDefsScreen: Bool = false
    @State var isShuffled: Bool = false
    
    @State var isTermScaled: Bool = false
    @State var isDefScaled: Bool = false
    @State var isScaledArray: [Bool] = []
    
    @State var isTextField: Bool = false
    @State var isEditButton : Bool = true
    
    var body: some View {
        List(selection: $selection) {
            ForEach(tmpNoteDetails) { noteDetail in
                noteDetailRow(noteDetail)
            }
            .onDelete(perform: deleteItems)
            .deleteDisabled(isShuffled)             // Shuffle 상태일 때 delete 못하게 함
        }
//        .animation(.default)                    // 해당 자리에 있어야 함
        .animation(.default)
        .onAppear() { copyNoteDetails() }
        .navigationBarTitle("\(note.title!)", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { add() }) {
                    Text("Add")
                }
                .disabled(editMode == .active)
            }
            ToolbarItem(placement: .navigationBarTrailing) { editButton.disabled(isEditButton == false) }
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
    }
}

extension NoteDetailView {
    func noteDetailRow(_ noteDetail: NoteDetail) -> some View {
        HStack {
            ZStack(alignment: .leading) {
//                noteDetailText(noteDetail.term, strokeColor: .blue)
                
//                noteDetailTextField("term", $note.term[noteDetail.order], strokeColor: .blue).disabled(editMode == .inactive)        // Animation 느려짐
                
//                if editMode == .inactive { noteDetailText(noteDetail.term, strokeColor: .blue) }
//                else { noteDetailTextField("term", $note.term[noteDetail.order], strokeColor: .blue) }
                
                if isTextField == false {
                    noteDetailText(noteDetail.term, strokeColor: .blue)
                    noteDetailScreen(noteDetail.order, strokeColor: .blue, isScreen: isTermsScreen, anchor: .leading)
                }
                else { noteDetailTextField("term", $note.term[noteDetail.order], strokeColor: .blue) }
            }
                
            ZStack(alignment: .trailing) {
//                noteDetailText(noteDetail.definition, strokeColor: .green)
                
//                noteDetailTextField("definition", $note.definition[noteDetail.order], strokeColor: .green).disabled(editMode == .inactive)        // Animation 느려짐
                
//                if editMode == .inactive { noteDetailText(noteDetail.definition, strokeColor: .green) }
//                else { noteDetailTextField("definition", $note.definition[noteDetail.order], strokeColor: .green) }
                
                if isTextField == false {
                    noteDetailText(noteDetail.definition, strokeColor: .green)
                    noteDetailScreen(noteDetail.order, strokeColor: .green, isScreen: isDefsScreen, anchor: .leading)
                }
                else { noteDetailTextField("definition", $note.definition[noteDetail.order], strokeColor: .green) }
            }
            
            Button(action: {
                changeMemorizedState(id: noteDetail.id)
            }) {
                if editMode == .inactive {
                    noteDetail.isMemorized == true ? Image(systemName: "square.fill") : Image(systemName: "square")
                }
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
    
    func noteDetailTextField(_ placeholder: String, _ text: Binding<String>, strokeColor: Color) -> some View {
        TextField(placeholder, text: text)
            .padding(.horizontal)
            .modifier(NoteDetailListModifier(strokeColor: strokeColor))
    }
    
    func noteDetailScreen(_ order: Int, strokeColor: Color, isScreen: Bool, anchor: UnitPoint) -> some View {
        Rectangle()
            .foregroundColor(strokeColor)
            .frame(width: 5)
            .scaleEffect(x: isScreen && !isScaledArray[order] ? 35 : 1, y: 1, anchor: anchor)
            .onTapGesture{}                 // Scroll 되게 하려면 필요(해당 자리에)
            .modifier(CustomGestureModifier(isPressed: $isScaledArray[order], f: { }))
    }
}

// MARK: - Tool Bar Items
extension NoteDetailView {
    var showingTermsButton: some View {
        Button(action: {
                if isDefsScreen == true {
                    isDefsScreen.toggle()
                    isDefScaled.toggle()
                }
                isTermsScreen.toggle()
                isTermScaled.toggle() }) {
            isTermsScreen == true ? Image(systemName: "arrow.left") : Image(systemName: "arrow.right")
        }
    }
    
    var shuffleButton: some View {
        Button(action: { shuffle() }) {
            isShuffled == true ? Image(systemName: "return") : Image(systemName: "shuffle")
        }
    }
    
    var showingDefsButton: some View {
        Button(action: {
                if isTermsScreen == true {
                    isTermsScreen.toggle()
                    isTermScaled.toggle()
                }
                isDefsScreen.toggle()
                isDefScaled.toggle() }) {
            isDefsScreen == true ? Image(systemName: "arrow.right") : Image(systemName: "arrow.left")
        }
    }
}


// MARK: - Other Functions
private extension NoteDetailView {
    func copyNoteDetails() {
        tmpNoteDetails = [NoteDetail]()
        
        for i in 0..<note.term.count {
            tmpNoteDetails.append(NoteDetail(order: i, term: note.term[i], definition: note.definition[i], isMemorized: note.isMemorized[i]))
            
            isScaledArray.append(Bool(false))
        }
    }
    
    func shuffle() -> Void {
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
        note.term.append("")
        note.definition.append("")
        note.isMemorized.append(false)
        
        tmpNoteDetails.append(NoteDetail(order: note.term.count - 1))
        saveContext()
        
        isScaledArray.append(Bool(false))
    }
    
    private var editButton: some View {
        
        if editMode == .inactive {
            return Button(action: {
                isEditButton = false
                isTermsScreen = false
                isDefsScreen = false
                if isShuffled { shuffle() }
                
                editMode = .active
                selection = Set<UUID>()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    isTextField = true
                    isEditButton = true
                }
            }) {
                Text("Edit")
            }
        }
        else {
            return Button(action: {
                isEditButton = false
                isTextField = false
                
                editMode = .inactive
                selection = Set<UUID>()
                
                saveContext()
                
//                copyNoteDetails()       // animation 때문에 사용 x
                for i in 0..<note.term.count {
//                    tmpNoteDetails[i] = NoteDetail(order: i, term: note.term[i], definition: note.definition[i], isMemorized: note.isMemorized[i])      // animation 때문에 사용 x
                    tmpNoteDetails[i].term = note.term[i]
                    tmpNoteDetails[i].definition = note.definition[i]
                }
                isEditButton = true
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
            
            for i in 0..<note.term.count { tmpNoteDetails[i].order = i }
        }) {
            Text("Delete")
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        note.term.remove(atOffsets: offsets)
        note.definition.remove(atOffsets: offsets)
        note.isMemorized.remove(atOffsets: offsets)

        tmpNoteDetails.remove(atOffsets: offsets)
        isScaledArray.remove(atOffsets: offsets)
        
        saveContext()
        
        // shuffle 상태에서 삭제하면 해당 구문이 return 못하게 함(shuffle 상태에서는 delete 못하게 함)
        for i in 0..<note.term.count { tmpNoteDetails[i].order = i }
    }
    
    func changeMemorizedState(id: UUID) {
        if let index = tmpNoteDetails.firstIndex(where: { $0.id == id }) {
            tmpNoteDetails[index].isMemorized.toggle()
            
            note.isMemorized[tmpNoteDetails[index].order] = tmpNoteDetails[index].isMemorized
            saveContext()
        }
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

