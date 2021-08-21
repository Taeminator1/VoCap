//
//  NoteDetailView.swift
//  VoCap
//
//  Created by 윤태민 on 12/9/20.
//

//  Inside of each note.

import SwiftUI
import GoogleMobileAds

struct NoteDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var note: Note
    
    @State var tmpNoteDetails: [NoteDetail] = []
    
    @State var editMode: EditMode = .inactive
    
    @State var cellLocation = CellLocation()
    @State var itemControl = ItemControl()
    
    @State var closeKeyboard: Bool = true
    @State var showingAddItemAlert: Bool = false
    
    @State var scrollTarget: Int?
    @State var listFrame: CGFloat = 0.0
    
    @Binding var tipControls: [TipControl]
    
    @State var orientation = UIDevice.current.orientation
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
                            scrollTarget = nil
                            withAnimation { proxy.scrollTo(tmpNoteDetails[target].id) }
                        }
                    }
                    .onAppear() {
                        UITableView.appearance().showsVerticalScrollIndicator = false
                        
                        copyNoteDetails()
                        listFrame = geometry.size.height > geometry.size.width ? geometry.size.height : geometry.size.width             // 없으면 .bottomBar 없어짐...
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            tipControls[TipType.tip0.rawValue].makeViewDisabled()
                        }
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
                        deleteMemorizedButton
                        showingButton(.definition)
                    }
                }
            }
            .accentColor(.mainColor)
        }
        .onReceive(orientationChanged) { _ in
            self.orientation = UIDevice.current.orientation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {         // 딜레이 안 주면 연속해서 Rotate했을 때, .bottom Toolbar 사라지는 문제 재발
                tipControls[TipType.tip0.rawValue].makeViewToggle()
            }
        }
    }
}


extension NoteDetailView {
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
                    closeKeyboard = true                // 없으면 키보드 잔상 남음
                }) {
                    noteDetail.isMemorized == true ? Image(systemName: "checkmark.square.fill").imageScale(.large) : Image(systemName: "square").imageScale(.large)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .modifier(NoteDetailListModifier(verticalPadding: -5))
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

extension NoteDetailView {
    func noteDetailText(_ text: String, bodyColor: Color, strokeColor: Color) -> some View {
        Text(text)
            .modifier(NoteDetailCellModifier2(bodyColor: bodyColor, strokeColor: strokeColor))
    }
    
    func NoteDetailTextField(_ title: String, _ text: Binding<String>, _ cellLocation: CellLocation, bodyColor: Color, strokeColor: Color) -> some View {
        // Keyboard Toolbar에서 열간 이동하기 위해 isFirstResponder 필요
        return CustomTextFieldWithToolbar(title: title, text: text, location: $cellLocation, closeKeyboard: $closeKeyboard, col: cellLocation.col, isFirstResponder: self.cellLocation == cellLocation)
            .modifier(NoteDetailCellModifier(bodyColor: bodyColor, strokeColor: strokeColor, lineWidth: 1.0))
    }
    
    func noteDetailScreen(_ order: Int, initialWidth: CGFloat = 4.0, _ stretchedWidth: CGFloat, _ screenColor: Color, _ isScreen: Bool, anchor: UnitPoint) -> some View {
        Rectangle()
            .foregroundColor(screenColor)
            .frame(width: initialWidth)
            .scaleEffect(x: isScreen && !tmpNoteDetails[order].isScaled ? stretchedWidth / initialWidth : 1.0, y: 1.0, anchor: anchor)
            .onTapGesture{}                 // Scroll 되게 하려면 필요(해당 자리에)
            .modifier(CustomGestureModifier(isPressed: $tmpNoteDetails[order].isScaled, f: { }))
    }
}

// MARK: - Tool Bar Items
extension NoteDetailView {
    var menuButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if editMode == .inactive {
                Menu {
                    addItemButton
                    editItemButton
                    hideMemorizedButton
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        tipControls[TipType.tip1.rawValue].makeViewDisabled()
                    }
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
    
    var deleteMemorizedButton: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Button(action: { deleteMemorized() }) {
                if editMode == .active {
                    Text("Delete Memorized")
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
extension NoteDetailView {
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        scrollTarget = note.itemCount - 1
                    }
                    showingAddItemAlert = true                               // To continue add item.
                }
            }
        }
    }
    
    func addItem(_ term: String, _ definition: String) {
        note.appendItem(term, definition)
        tmpNoteDetails.append(NoteDetail(order: note.itemCount - 1, term, definition))
        viewContext.saveContext()
    }
    
    var editItemButton: some View {
        Button(action: {
            cellLocation = CellLocation()
            itemControl = ItemControl()
            
            if itemControl.isShuffled { shuffle() }             // If items are shuffled, return back.
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {        // for animation
                editMode = .active
            }
        }) {
            Label("Edit item", systemImage: "pencil")
        }
    }
    
    var doneButton: some View {
        Button(action: {
            editMode = .inactive
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {        // 없으면 Keyboard 뒤 배경 안 사라짐
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
}


// MARK: - Other Functions
extension NoteDetailView {
    func copyNoteDetails() {
        Array(0 ..< note.itemCount).forEach {
            tmpNoteDetails.append(NoteDetail(order: $0, note.findItem(at: $0)))
        }
    }
}


// MARK: - Modify NoteDetails rows
extension NoteDetailView {
    func deleteMemorized() -> Void {      // TextField를 없애면 에러 발생
        var selection = Set<UUID>()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {            // 없으면 Keyboard 뒤 배경 안 사라짐
            Array(0 ..< note.itemCount).forEach {
                if note.isMemorized[$0] {
                    selection.insert(tmpNoteDetails[$0].id)
                }
            }
            
            selection.forEach { id in
                if let index = tmpNoteDetails.lastIndex(where: { $0.id == id })  {
                    note.removeItem(at: index)
                    tmpNoteDetails.remove(at: index)
                }
            }
            viewContext.saveContext()
            
            Array(0 ..< note.itemCount).forEach { tmpNoteDetails[$0].order = $0 }
        }
    }
    
    func deleteItem(atOffsets offsets: IndexSet) {         // edit 상태에서 마지막꺼 지우면 에러 발생
        note.removeItem(atOffsets: offsets)
        tmpNoteDetails.remove(atOffsets: offsets)
        viewContext.saveContext()
        
        Array(0 ..< note.itemCount).forEach { tmpNoteDetails[$0].order = $0 }
    }
    
    func changeMemorizedState(id: UUID) {
        if let index = tmpNoteDetails.firstIndex(where: { $0.id == id }) {
            tmpNoteDetails[index].isMemorized.toggle()
            
            note.isMemorized[tmpNoteDetails[index].order] = tmpNoteDetails[index].isMemorized
            viewContext.saveContext()
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

