//
//  NoteDetailView.swift
//  VoCap
//
//  Created by 윤태민 on 12/9/20.
//

//  Inside of each note:
//  - Menu
//      - Add item.
//      - Edit item.
//      - Hide memorized.
//      - Delete memorized.
//  - List of Items
//  - Block
//      - Terms.
//      - Definitions.
//  - Shuffle

//  Tip shows when isDisabled is true and userDefault is false in TipControl instance.

import SwiftUI
import GoogleMobileAds

struct NoteDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var note: Note
    
    @State private var tmpNoteDetails: [NoteDetail] = []
    
    @State private var editMode: EditMode = .inactive
    
    @State private var cellLocation = CellLocation()
    @State private var itemControl = ItemControl()
    
    @State private var closeKeyboard: Bool = true
    @State private var showingAddItemAlert: Bool = false
    
    @State private var scrollTarget: Int?
    @State private var listFrame: CGFloat = 0.0
    
    @Binding var tipControls: [TipControl]
    
    @State private var orientation = UIDevice.current.orientation
    let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .makeConnectable()
            .autoconnect()
    let limitedNumberOfItems: Int = 500
    
    var body: some View {
        VStack {
            GADBannerViewController()
                .frame(width: kGADAdSizeBanner.size.width, height: kGADAdSizeBanner.size.height)
            
            GeometryReader { geometry in
                ScrollViewReader { proxy in
                    List {
                        ForEach(tmpNoteDetails) { noteDetail in
                            noteDetailRow(noteDetail)
                        }
                        .onDelete(perform: deleteItem)
                        .deleteDisabled(itemControl.isShuffled || editMode == .active)
                    }
                    .animation(.default)
                    .alert(isPresented: $showingAddItemAlert, textAlert)
                    .onChange(of: scrollTarget) {
                        if let target = $0 {
                            print(target)
                            print(tmpNoteDetails.count)
                            scrollTarget = nil
                            withAnimation { proxy.scrollTo(tmpNoteDetails[target].id) }
                        }
                    }
                    .onAppear() {
                        UITableView.appearance().showsVerticalScrollIndicator = false
                        
                        copyNoteDetails()
                        listFrame = geometry.size.height > geometry.size.width ? geometry.size.height : geometry.size.width     // .bottomBar가 사라지는 것 방지
                        
                        tipControls[TipType.tip0.rawValue].makeViewDisabled()
                    }
                    .onDisappear() {
                        Array(0 ..< tipControls.count).forEach { tipControls[$0].makeViewEnabled() }
                    }
                    .navigationBarTitle("\(note.title!)", displayMode: .inline)
                    .toolbar {
                        // NavigationBar
                        menuButton
                        
                        // BottomBar
                        showingButton(.term)
                        Separator(placement: .bottomBar)
                        shuffleButton
                        Separator(placement: .bottomBar)
                        showingButton(.definition)
                    }
                }
            }
            .accentColor(.mainColor)
        }
        .onReceive(orientationChanged) { _ in
            self.orientation = UIDevice.current.orientation
            tipControls[TipType.tip0.rawValue].makeViewToggle()     // .bottomBar가 사라지는 것 방지
        }
    }
}


private extension NoteDetailView {
    @ViewBuilder
    func noteDetailRow(_ noteDetail: NoteDetail) -> some View {
        if !(noteDetail.isMemorized && itemControl.hideMemorized) {
            HStack {
                ForEach(0 ..< TextFieldType.allCases.count) { col in
                    noteDetailCell(noteDetail, TextFieldType(rawValue: col) ?? .term)
                        .onTapGesture {
                            cellLocation = CellLocation(noteDetail.order, col)
                            if editMode == .active { scrollTarget = noteDetail.order }
                        }
                }
                
                Button(action: {
                    if editMode == .active {
                        CustomUITextField(location: $cellLocation, closeKeyboard: $closeKeyboard)
                            .done(button: UIBarButtonItem())
                        scrollTarget = noteDetail.order
                    }
                    changeMemorizedState(id: noteDetail.id)
                    closeKeyboard = true                            // 키보드 잔상 방지
                }) {
                    noteDetail.isMemorized == true ? Image(systemName: "checkmark.square.fill").imageScale(.large) : Image(systemName: "square").imageScale(.large)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .listRowStyle(.noteDetailRow)
        }
    }
    
    func noteDetailCell(_ noteDetail: NoteDetail, _ selectedCol: TextFieldType) -> some View {
        return ZStack {
            switch selectedCol {
            case .term:
                if editMode == .inactive {
                    noteDetailText(noteDetail.term, bodyColor: .textBodyColor, strokeColor: .tScreenColor)
                    GeometryReader { geometry in
                        HStack {
                            noteDetailScreen(noteDetail.order, geometry.size.width, .tScreenColor, itemControl.screen.left, anchor: .leading)
                            Spacer()
                        }
                    }
                }
                else {
                    NoteDetailTextField("Term", $note.term[noteDetail.order], CellLocation(noteDetail.order, 0), bodyColor: .textFieldBodyColor, strokeColor: .tTextFieldStrokeColor)
                }
            case .definition:
                if editMode == .inactive {
                    noteDetailText(noteDetail.definition, bodyColor: .textBodyColor, strokeColor: .dScreenColor)
                    GeometryReader { geometry in
                        HStack {
                            Spacer()
                            noteDetailScreen(noteDetail.order, geometry.size.width, .dScreenColor, itemControl.screen.right, anchor: .trailing)
                        }
                    }
                }
                else {
                    NoteDetailTextField("Definition", $note.definition[noteDetail.order], CellLocation(noteDetail.order, 1), bodyColor: .textFieldBodyColor, strokeColor: .dTextFieldStrokeColor)
                }
            }
        }
    }
}

private extension NoteDetailView {
    func noteDetailText(_ text: String, bodyColor: Color, strokeColor: Color) -> some View {
        Text(text)
            .noteDetailTextStyle()
            .noteDetailTextFieldStyle(bodyColor: bodyColor, strokeColor: strokeColor)
    }
    
    func NoteDetailTextField(_ title: String, _ text: Binding<String>, _ cellLocation: CellLocation, bodyColor: Color, strokeColor: Color) -> some View {
        // Keyboard Toolbar에서 Keyboard가 열린채로 열간 이동하기 위해 isFirstResponder 필요
        return CustomTextFieldWithToolbar(title: title, text: text, location: $cellLocation, closeKeyboard: $closeKeyboard, isFirstResponder: self.cellLocation == cellLocation)
            .noteDetailTextFieldStyle(bodyColor: bodyColor, strokeColor: strokeColor, lineWidth: 1.0)
    }
    
    func noteDetailScreen(_ order: Int, initialWidth: CGFloat = 4.0, _ stretchedWidth: CGFloat, _ screenColor: Color, _ isScreen: Bool, anchor: UnitPoint) -> some View {
        Rectangle()
            .foregroundColor(screenColor)
            .frame(width: initialWidth)
            .scaleEffect(x: isScreen && !tmpNoteDetails[order].isScaled ? stretchedWidth / initialWidth : 1.0, y: 1.0, anchor: anchor)
            .onTapGesture{}                 // Scroll 위해 필요
            .modifier(CustomGestureModifier(isPressed: $tmpNoteDetails[order].isScaled, f: { }))
    }
}

// MARK: - Tool Bar Items
private extension NoteDetailView {
    var menuButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if editMode == .inactive {
                Menu {
                    addItemButton
                    editItemButton
                    hideMemorizedButton
                    deleteMemorizedButton
                }
                label: { Label("", systemImage: "ellipsis.circle").imageScale(.large) }
            }
            else {
                doneButton
            }
        }
    }
    
    func showingButton(_ column: TextFieldType) -> some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Button(action: {
                withAnimation {
                    tipControls[TipType.tip1.rawValue].makeViewDisabled()
                }
                column == .term ? itemControl.toggleLeft() : itemControl.toggleRight()
            }) {
                if editMode == .inactive {
                    switch(column) {
                    case .term:
                        itemControl.screen.left ? Image("arrow.right.on").imageScale(.large) : Image("arrow.right.off").imageScale(.large)
                    case .definition:
                        itemControl.screen.right ? Image("arrow.left.on").imageScale(.large) : Image("arrow.left.off").imageScale(.large)
                    }
                }
            }
        }
    }
    
    var shuffleButton: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Button(action: { shuffle() }) {
                if editMode == .inactive {
                    itemControl.isShuffled ? Image("shuffle.on").imageScale(.large) : Image("shuffle.off").imageScale(.large)
                }
            }
        }
    }
    
    func shuffle() -> Void {
        itemControl.isShuffled.toggle()
        itemControl.isShuffled ? tmpNoteDetails.shuffle() : tmpNoteDetails.sort { $0.order < $1.order }
    }
}


// MARK: - Menu
private extension NoteDetailView {
    var addItemButton: some View {
        Button(action: { showingAddItemAlert = true }) {
            Label("Add Item", systemImage: "plus")
        }
    }
  
    var textAlert: TextAlert {
        TextAlert(title: "Add Item".localized, message: "Enter a term and a definition to memorize. ".localized) { term, definition  in
            if let term = term, let definition = definition {
                if (note.itemCount < limitedNumberOfItems && term != "" || definition != "") {
                    addItem(term, definition)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {     // 신규 아이템을 UI에 그리는 시간 필요
                        scrollTarget = note.itemCount - 1
                    }
                    showingAddItemAlert = true                                  // To continue add item.
                }
            }
        }
    }
    
    func addItem(_ term: String, _ definition: String) {
//        DispatchQueue.global().sync {
            note.appendItem(term, definition)
            tmpNoteDetails.append(NoteDetail(order: note.itemCount - 1, term, definition))
            viewContext.saveContext()
//            scrollTarget = note.itemCount - 1
//        }
        
    }
    
    var editItemButton: some View {
        Button(action: {
            cellLocation = CellLocation()
            itemControl = ItemControl()
            
            if itemControl.isShuffled { shuffle() }             // If items are shuffled, return back.
            editMode = .active
        }) {
            Label("Edit Item", systemImage: "pencil")
        }
    }
    
    var doneButton: some View {
        Button(action: {
            editMode = .inactive
            
            // 편집하고 Done 누른 다음, 홈 화면으로 가면 아래 키보드 잔상 생기는 것 방지
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                closeKeyboard = true
            }
            viewContext.saveContext()
            
            Array(0 ..< note.itemCount).forEach {
                tmpNoteDetails[$0].term = note.term[$0]
                tmpNoteDetails[$0].definition = note.definition[$0]
            }
        }) {
            Text("Done")
        }
    }
    
    var hideMemorizedButton: some View {
        Button(action: { itemControl.hideMemorized.toggle() }) {
            itemControl.hideMemorized ? Label("Show Memorized", systemImage: "eye") : Label("Hide Memorized", systemImage: "eye.slash")
        }
    }
    
    var deleteMemorizedButton: some View {
        Button(action: {
            deleteMemorized()
        }) {
            Label("Delete Memorized", systemImage: "trash")
        }
    }
    
    func deleteMemorized() -> Void {
        var selection = Set<UUID>()
        
        Array(0 ..< note.itemCount).forEach {
            if note.isMemorized[$0] {
                selection.insert(tmpNoteDetails[$0].id)
            }
        }
        
        selection.forEach { id in
            if let index = tmpNoteDetails.firstIndex(where: { $0.id == id })  {
                note.removeItem(at: index)
                tmpNoteDetails.remove(at: index)
            }
        }
        makeOrder()
    }
}


// MARK: - Other Functions
private extension NoteDetailView {
    func copyNoteDetails() {
        Array(0 ..< note.itemCount).forEach {
            tmpNoteDetails.append(NoteDetail(order: $0, note.findItem(at: $0)))
        }
    }
}


// MARK: - Modify NoteDetails rows
private extension NoteDetailView {
    func deleteItem(atOffsets offsets: IndexSet) {
        note.removeItem(atOffsets: offsets)
        tmpNoteDetails.remove(atOffsets: offsets)
        makeOrder()
    }
    
    func changeMemorizedState(id: UUID) {
        if let index = tmpNoteDetails.firstIndex(where: { $0.id == id }) {
            tmpNoteDetails[index].isMemorized.toggle()
            
            note.isMemorized[tmpNoteDetails[index].order] = tmpNoteDetails[index].isMemorized
            viewContext.saveContext()
        }
    }
    
    func makeOrder() {
        viewContext.saveContext()
        Array(0 ..< note.itemCount).forEach { tmpNoteDetails[$0].order = $0 }
        viewContext.saveContext()
    }
}
