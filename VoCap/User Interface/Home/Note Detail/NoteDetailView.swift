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

struct NoteDetailView: View {
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
    @State var isAddButton: Bool = true
    @State private var showingAddItemAlert: Bool = false
    
    @State private var scrollTarget: Int?
    
    @State private var selectedRow = -1
    @State private var selectedCol = -1
    
    @State var closeKeyboard: Bool = true
    @State var listFrame: CGFloat = 0.0
    
    let limitedNumberOfItems: Int = 600
    
    @Binding var isDisabled: Bool
    
    let alertController = UIAlertController(title: "Alert", message: "Please enter text", preferredStyle: .alert)
    
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
                .animation(.default)
//                .alert(isPresented: $showingAddItemAlert, TextAlert(title: "Title", message: "Message", action: { result in
//                              if let text = result { print("\(text)") }
//                              else { print("else") }
//                }))
                .alert(isPresented: $showingAddItemAlert, XxTextAlert(title: "Add Item", message: "Enter term and definition to memorize. ", action: { term, definition  in
                    if let term = term, let definition = definition {
                        print("Next")
                        if term != "" && definition != "" && note.term.count < limitedNumberOfItems {
                            add(term, definition)

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {         // 딜레이 안 주면 추가한 목록이 안 보임
                                scrollTarget = note.term.count - 1
                            }
                            showingAddItemAlert = true
                        }
                        else {
                            print("Cancel")
                        }
                    }
                    else {
                        print("Cancel")
                    }
                }))
//                .frame(height: listFrame)
                .onChange(of: scrollTarget) { target in
                    if let target = target {
                        scrollTarget = nil
//                        withAnimation { proxy.scrollTo(tmpNoteDetails[target].id, anchor: .bottom) }
                        withAnimation { proxy.scrollTo(tmpNoteDetails[target].id) }
                    }
                }
                .onAppear() {
                    UITableView.appearance().showsVerticalScrollIndicator = false
                    
                    copyNoteDetails()
                    listFrame = geometry.size.height > geometry.size.width ? geometry.size.height : geometry.size.width             // 없으면 .bottomBar 없어짐...
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if note.term.count == 0 {
                            showingAddItemAlert = true
                        }
                    }
                }
                .onDisappear() {
                    isDisabled = false
                }
                .navigationBarTitle("\(note.title!)", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            withAnimation {
                                isDisabled.toggle()
                            }
                        }) { Text("Test") }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if editMode == .inactive {
                            Menu {
//                                addButton.disabled(isAddButton == false)
                                xXaddButton.disabled(isAddButton == false)
                                editButton.disabled(isEditButton == false)
                                hideMemorizedButton
                            }
                            label: { Label("", systemImage: "ellipsis.circle").imageScale(.large) }
                        }
                        else {
                            doneButton
                        }
                    }
                    
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
    }
}

// MARK: - Menu
extension NoteDetailView {
    var xXaddButton: some View {
        Button(action: {
            showingAddItemAlert = true
        }) {
            Label("Add Items", systemImage: "plus")
        }
    }
    
    private var addButton: some View {
        Button(action: {
            isAddButton = false
            
            if note.term.count < limitedNumberOfItems { add() }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isAddButton = true
            }
        }) {
            Label("Add Item", systemImage: "plus")
        }
    }
  
    var editButton: some View {
        Button(action: {
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
            Label("Edit item", systemImage: "pencil")
        }
    }
    
    var doneButton: some View {
        Button(action: {
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
    
    
    var hideMemorizedButton: some View {
        Button(action: { isHidingNoteDetails.toggle() }) {
            isHidingNoteDetails == true ? Label("Show Memorized", systemImage: "eye") : Label("Hide Memorized", systemImage: "eye.slash")
        }
    }
    
    
    func add() {
        for i in 0..<500 {
            note.term.append("\(i)")
            note.definition.append("\(i)")
            note.isMemorized.append(false)
            
            tmpNoteDetails.append(NoteDetail(order: note.term.count - 1))
            saveContext()
        
            isScaledArray.append(Bool(false))
        }
        
        scrollTarget = note.term.count - 1
    }
    
    func add(_ term: String, _ definitino: String) {
//        for i in 0..<50 {
        note.term.append(term)
        note.definition.append(definitino)
        note.isMemorized.append(false)
        
//        tmpNoteDetails.append(NoteDetail(order: note.term.count - 1))
//        tmpNoteDetails.append(NoteDetail(order: note.term.count - 1, term: note.term, definition: note.definition))
        let index = note.term.count - 1
        tmpNoteDetails.append(NoteDetail(order: index, term: note.term[index], definition: note.definition[index]))
        saveContext()
    
        isScaledArray.append(Bool(false))
//        }
    }
}

extension NoteDetailView {
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
                    noteDetail.isMemorized == true ? Image(systemName: "checkmark.square.fill").imageScale(.large) : Image(systemName: "square").imageScale(.large)
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
                    noteDetailText(noteDetail.term, bodyColor: .textBodyColor, strokeColor: .tTextStrokeColor)
                    GeometryReader { geometry in
                        HStack {
                            noteDetailScreen(noteDetail.order, finalWidth: geometry.size.width, screenColor: .tScreenColor, isScreen: isTermsScreen, anchor: .leading)
                            Spacer()
                        }
                    }
                }
                else {
                    NoteDetailTextField("Term", $note.term[noteDetail.order], noteDetail.order, 0, bodyColor: .textFieldBodyColor, strokeColor: .tTextFieldStrokeColor)
                }
            case 1:
                if isTextField == false {
                    noteDetailText(noteDetail.definition, bodyColor: .textBodyColor, strokeColor: .dTextStrokeColor)
                    GeometryReader { geometry in
                        HStack {
                            Spacer()
                            noteDetailScreen(noteDetail.order, finalWidth: geometry.size.width, screenColor: .dScreenColor, isScreen: isDefsScreen, anchor: .trailing)     // 여기는 + 1 안함
                        }
                    }
                }
                else {
                    NoteDetailTextField("definition", $note.definition[noteDetail.order], noteDetail.order, 1, bodyColor: .textFieldBodyColor, strokeColor: .dTextFieldStrokeColor)
                }
                
            default:
                Text("Error")
            }
        }
//        .ignoresSafeArea(.keyboard)
    }
}

extension NoteDetailView {
    func noteDetailText(_ text: String, bodyColor: Color, strokeColor: Color) -> some View {
        Text(text)
            .font(.body)
            .minimumScaleFactor(0.8)
            .lineLimit(2)
            .padding(.horizontal)
            .modifier(NoteDetailListModifier(bodyColor: bodyColor, strokeColor: strokeColor))
    }
    
    func NoteDetailTextField(_ title: String, _ text: Binding<String>, _ row: Int, _ col: Int, bodyColor: Color, strokeColor: Color) -> some View {

        var responder: Bool {
            return row == selectedRow && col == selectedCol
        }
        
        return CustomTextFieldWithToolbar(title: title, text: text, selectedRow: $selectedRow, selectedCol: $selectedCol, isEnabled: $isTextField, closeKeyboard: $closeKeyboard, col: col, isFirstResponder: responder)
            .padding(.horizontal)
            .modifier(NoteDetailListModifier(bodyColor: bodyColor, strokeColor: strokeColor, lineWidth: 1.0))
    }
    
    func noteDetailScreen(_ order: Int, initWidth: CGFloat = 4.0, finalWidth: CGFloat, screenColor: Color, isScreen: Bool, anchor: UnitPoint) -> some View {
        Rectangle()
            .foregroundColor(screenColor)
            .frame(width: initWidth)
            .scaleEffect(x: isScreen && !isScaledArray[order] ? finalWidth / initWidth : 1.0, y: 1.0, anchor: anchor)
            .onTapGesture{}                 // Scroll 되게 하려면 필요(해당 자리에)
            .modifier(CustomGestureModifier(isPressed: $isScaledArray[order], f: { }))
    }
}

// MARK: - Tool Bar Items
extension NoteDetailView {
    var showingTermsButton: some View {
        Button(action: {
            withAnimation {
                isDisabled.toggle()
            }
            
            if isDefsScreen == true {
                isDefsScreen.toggle()
                isDefScaled.toggle()
            }
            isTermsScreen.toggle()
            isTermScaled.toggle()
        }) {
//            isTermsScreen == true ? Image(systemName: "arrow.left") : Image(systemName: "arrow.right")
            isTermsScreen == true ? Image("arrow.right.on").imageScale(.large) : Image("arrow.right.off").imageScale(.large)
        }
    }
    
    var shuffleButton: some View {
        Button(action: { shuffle() }) {
//            isShuffled == true ? Image(systemName: "return") : Image(systemName: "shuffle")
            isShuffled == true ? Image("shuffle.on").imageScale(.large) : Image("shuffle.off").imageScale(.large)
        }
    }
    
    var showingDefsButton: some View {
        Button(action: {
            withAnimation {
                isDisabled.toggle()
            }
            
            if isTermsScreen == true {
                isTermsScreen.toggle()
                isTermScaled.toggle()
            }
            isDefsScreen.toggle()
            isDefScaled.toggle()
        }) {
//            isDefsScreen == true ? Image(systemName: "arrow.right") : Image(systemName: "arrow.left")
            isDefsScreen == true ? Image("arrow.left.on").imageScale(.large) : Image("arrow.left.off").imageScale(.large)
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

