//
//  NoteDetailView.swift
//  VoCap
//
//  Created by 윤태민 on 12/9/20.
//

import SwiftUI

enum TextFieldType: Int {
    case Term = 0
    case Definition = 1
}

struct YyNoteDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var note: Note          // @State할 때는, 값이 바뀌어도 갱신이 안 됨,
    
    @State var tmpNoteDetails: [NoteDetail] = []
    
    @State var editMode: EditMode = .inactive
    @State var selection = Set<UUID>()
    
    @State var isTermsScreen: Bool = false
    @State var isHidingNoteDetails: Bool = false
    @State var isShuffled: Bool = false
    @State var isDefsScreen: Bool = false
    
    @State var isTermScaled: Bool = false
    @State var isDefScaled: Bool = false
    @State var isScaledArray: [Bool] = []
    
    @State var isTextField: Bool = false
    @State var isEditButton : Bool = true
    
    @State private var scrollTarget: Int?
    
    @State private var selectedRow = -1
    @State private var selectedCol = -1
    
    @State var closeKeyboard: Bool = true
    @State var listFrame: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                List(selection: $selection) {
                    ForEach(tmpNoteDetails) { noteDetail in
                        noteDetailRow(noteDetail)
                    }
                    .onDelete(perform: deleteItems)
                    .deleteDisabled(isShuffled)             // Shuffle 상태일 때 delete 못하게 함
                }
                .frame(height: listFrame)
                .onChange(of: scrollTarget) { target in
                    if let target = target {
                        scrollTarget = nil
    //                    withAnimation { proxy.scrollTo(tmpNoteDetails[target].id, anchor: .bottom) }
                        withAnimation {
                            proxy.scrollTo(tmpNoteDetails[target].id)
                        }
                    }
                }
                .animation(.default)
                .onAppear() {
                    copyNoteDetails()
                    listFrame = geometry.size.height > geometry.size.width ? geometry.size.height : geometry.size.width
                }
                .navigationBarTitle("\(note.title!)", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            if listFrame == 500 {
                                listFrame = 700
                            }
                            else {
                                listFrame = 500
                            }
                            print(listFrame)
                        }) {
                            Text("Test")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) { editButton.disabled(isEditButton == false) }
                    
                    ToolbarItem(placement: .bottomBar) {
                        if editMode == .inactive { showingTermsButton }
                        else { addButton }
                    }
                    ToolbarItem(placement: .bottomBar) { Spacer() }
                    ToolbarItem(placement: .bottomBar) { if editMode == .inactive { hidingMemorizedNoteDetails } }
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
    }
}

extension YyNoteDetailView {
    @ViewBuilder        // 없으면 Function declares an opaque return type ... error 발생
    func noteDetailRow(_ noteDetail: NoteDetail) -> some View {
        if noteDetail.isMemorized && isHidingNoteDetails {
            EmptyView()
        }
        else {
            HStack {
                ForEach(0 ..< 2) { col in
                    noteDetailCell(noteDetail, col)
                        .onTapGesture {
                            selectedRow = noteDetail.order
                            selectedCol = col           // 여기 있으면 Keyboard 뒤에 View가 안 없어지는 경우 생김
                            if isTextField { scrollTarget = noteDetail.order }
                        }
                }
                
                Button(action: {
                    changeMemorizedState(id: noteDetail.id)
                }) {
                    if editMode == .inactive {
                        noteDetail.isMemorized == true ? Image(systemName: "square.fill") : Image(systemName: "square")
                    }
                }
            }
            .padding()
            .modifier(HomeViewNoteRowModifier())
        }
    }
    
    func noteDetailCell(_ noteDetail: NoteDetail, _ selectedCol: Int) -> some View {
        return ZStack {
            switch selectedCol {
            case 0:
                if isTextField == false {
                    noteDetailText(noteDetail.term, strokeColor: .blue)
                    GeometryReader { geometry in
                        HStack {
                            noteDetailScreen(noteDetail.order, initWidth: 5.0, finalWidth: geometry.size.width + 1, strokeColor: .blue, isScreen: isTermsScreen, anchor: .leading)     // 여기는 + 1 함
                            Spacer()
                        }
                    }
                }
                else {
                    yyNoteDetailTextField("Term", $note.term[noteDetail.order], noteDetail.order, 0, strokeColor: .blue)
                }
            case 1:
                if isTextField == false {
                    noteDetailText(noteDetail.definition, strokeColor: .green)
                    GeometryReader { geometry in
                        HStack {
                            Spacer()
                            noteDetailScreen(noteDetail.order, initWidth: 5.0, finalWidth: geometry.size.width, strokeColor: .green, isScreen: isDefsScreen, anchor: .trailing)     // 여기는 + 1 안함
                        }
                    }
                }
                else {
                    yyNoteDetailTextField("definition", $note.definition[noteDetail.order], noteDetail.order, 1, strokeColor: .green)
                }
                
            default:
                Text("Error")
            }
        }
    }
}

extension YyNoteDetailView {
    func noteDetailText(_ text: String, strokeColor: Color) -> some View {
        Text(text)
            .font(.body)
            .lineLimit(2)
            .padding(.horizontal)
            .modifier(NoteDetailListModifier(strokeColor: strokeColor))
    }
    
    func yyNoteDetailTextField(_ title: String, _ text: Binding<String>, _ row: Int, _ col: Int, strokeColor: Color) -> some View {

        var responder: Bool {
            return row == selectedRow && col == selectedCol
        }
        
        return YyCustomTextField(title: title, text: text, selectedRow: $selectedRow, selectedCol: $selectedCol, isEnabled: $isTextField, closeKeyboard: $closeKeyboard, isFirstResponder: responder)
            .padding(.horizontal)
            .modifier(NoteDetailListModifier(strokeColor: strokeColor))
    }
    
    func noteDetailScreen(_ order: Int, initWidth: CGFloat = 1.0, finalWidth: CGFloat = 1.0, strokeColor: Color, isScreen: Bool, anchor: UnitPoint) -> some View {
        Rectangle()
            .foregroundColor(strokeColor)
            .frame(width: initWidth)
            .scaleEffect(x: isScreen && !isScaledArray[order] ? finalWidth / initWidth : 1.0, y: 1.0, anchor: anchor)
            .onTapGesture{}                 // Scroll 되게 하려면 필요(해당 자리에)
            .modifier(CustomGestureModifier(isPressed: $isScaledArray[order], f: { }))
    }
}

// MARK: - Tool Bar Items
extension YyNoteDetailView {
    var showingTermsButton: some View {
        Button(action: {
                if isDefsScreen == true {
                    isDefsScreen.toggle()
                    isDefScaled.toggle()
                }
                isTermsScreen.toggle()
                isTermScaled.toggle()
        }) {
            isTermsScreen == true ? Image(systemName: "arrow.left") : Image(systemName: "arrow.right")
        }
    }
    
    var hidingMemorizedNoteDetails: some View {
        Button(action: { isHidingNoteDetails.toggle() }) {
            isHidingNoteDetails == true ? Image(systemName: "eye") : Image(systemName: "eye.slash")
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
                isDefScaled.toggle()
        }) {
            isDefsScreen == true ? Image(systemName: "arrow.right") : Image(systemName: "arrow.left")
        }
    }
}


// MARK: - Other Functions
private extension YyNoteDetailView {
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
extension YyNoteDetailView {
    func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private var addButton: some View {
        Button(action: { add() }) {
            Text("Add")
        }
    }
    func add() {
        note.term.append("")
        note.definition.append("")
        note.isMemorized.append(false)
        
        tmpNoteDetails.append(NoteDetail(order: note.term.count - 1))
        saveContext()
        
        isScaledArray.append(Bool(false))
        
        scrollTarget = note.term.count - 1
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {            // for animation
//            selectedRow = note.term.count - 1
//            selectedCol = 0
//        }
    }
    
    private var editButton: some View {
        if editMode == .inactive {
            return Button(action: {
                isEditButton = false
                isTermsScreen = false
                isDefsScreen = false
                isHidingNoteDetails = false
                
                selectedRow = -1
                selectedCol = -1
                closeKeyboard = false
                
                if isShuffled { shuffle() }
                
                editMode = .active
                selection = Set<UUID>()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {            // for animation
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {            // 없으면 Keyboard 뒤 배경 안 사라짐
                    closeKeyboard = true
                    isEditButton = true
                }
                
                saveContext()
                
                for i in 0..<note.term.count {
                    tmpNoteDetails[i].term = note.term[i]
                    tmpNoteDetails[i].definition = note.definition[i]
                }
                
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

