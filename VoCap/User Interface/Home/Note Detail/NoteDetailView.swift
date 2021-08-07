//
//  NoteDetailView.swift
//  VoCap
//
//  Created by 윤태민 on 12/9/20.
//

import SwiftUI
import GoogleMobileAds

struct NoteDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var note: Note          // @State할 때는, 값이 바뀌어도 갱신이 안 됨,
    
    @State var tmpNoteDetails: [NoteDetail] = []
    
    @State var editMode: EditMode = .inactive
    @State var selection = Set<UUID>()
    
    @State var itemLocation = ItemLocation()
    @State var itemControl = ItemControl()
    
    @State var isEditMode: Bool = false
    @State var closeKeyboard: Bool = true
    @State var showingAddItemAlert: Bool = false
    
    @State var scrollTarget: Int?
    @State var listFrame: CGFloat = 0.0
    
//    let limitedNumberOfItems: Int = 500
    @Binding var isDisableds: [Bool]
    
    @State var orientation = UIDevice.current.orientation
    let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .makeConnectable()
            .autoconnect()
    
    var body: some View {
        VStack {
            GADBannerViewController()
                .frame(width: kGADAdSizeBanner.size.width, height: kGADAdSizeBanner.size.height)        // Frame 사이즈 변경 가능(실제 앱 구동하는 것 보고 변경 여부 결정)
            
            GeometryReader { geometry in
                ScrollViewReader { proxy in
//                    List(selection: $selection) {
                    List {
                        ForEach(tmpNoteDetails) { noteDetail in
                            noteDetailRow(noteDetail)
                        }
                        .onDelete(perform: deleteItem)
                        .deleteDisabled(itemControl.isShuffled || editMode == .active)             // Shuffle 상태일 때 delete 못하게 함
                    }
                    .animation(.default)
                    .alert(isPresented: $showingAddItemAlert, textAlert)
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
                            withAnimation {
                                isDisableds[0].toggle()
                            }
                        }
                    }
                    .onDisappear() {
                        isDisableds = isDisableds.map { _ in false }
                    }
                    .navigationBarTitle("\(note.title!)", displayMode: .inline)
                    .toolbar {
                        // NavigationBar
                        menuButton
                        
                        // BottomBar
                        showingButton(.term)
                        spacer
                        shuffleButton
                        spacer
                        deleteMemorizedButton
                        showingButton(.definition)
                    }
                    .environment(\.editMode, self.$editMode)          // 해당 위치에 없으면 editMode 안 먹힘
                }
            }
            .accentColor(.mainColor)
        }
        .onReceive(orientationChanged) { _ in                   // XxTextAlert을 추가하면 rotate 시, .bottom Toolbar가 사라져 방지하기 위함
            self.orientation = UIDevice.current.orientation
//            print(orientation.isLandscape)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {         // 딜레이 안 주면 연속해서 Rotate했을 때, .bottom Toolbar 사라지는 문제 재발
                isDisableds[0].toggle()
            }
        }
    }
}

// MARK: - Menu
extension NoteDetailView {
    var addItemButton: some View {
        Button(action: {
            showingAddItemAlert = true
        }) {
            Label("Add Item", systemImage: "plus")
        }
    }
  
    var textAlert: TextAlert {
        TextAlert(title: "Add Item".localized, message: "Enter a term and a definition to memorize. ".localized, action: { term, definition  in
            if let term = term, let definition = definition {
                if (term != "" || definition != "") {           // && note.itemCount < limitedNumberOfItems
                    addItem(term, definition)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {         // 딜레이 안 주면 추가한 목록이 안 보임
                        scrollTarget = note.itemCount - 1
                    }
                    showingAddItemAlert = true
                }
            }
        })
    }
    
    var editItemButton: some View {
        Button(action: {
            itemLocation = ItemLocation()
            itemControl = ItemControl()
            
            closeKeyboard = false
            
            if itemControl.isShuffled { shuffle() }
            
            editMode = .active
            selection = Set<UUID>()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {            // for animation
                isEditMode = true
            }
        }) {
            Label("Edit item", systemImage: "pencil")
        }
    }
    
    var doneButton: some View {
        Button(action: {
            isEditMode = false
            
            editMode = .inactive
            selection = Set<UUID>()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {            // 없으면 Keyboard 뒤 배경 안 사라짐
                closeKeyboard = true
            }
            
            saveContext()
            
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
            itemControl.hideMemorized == true ? Label("Show Memorized", systemImage: "eye") : Label("Hide Memorized", systemImage: "eye.slash")
        }
    }
    
    func addItem(_ term: String, _ definition: String) {
        note.appendItem(term, definition)
        tmpNoteDetails.append(NoteDetail(order: note.itemCount - 1, term, definition))
        saveContext()
    }
}

extension NoteDetailView {
    @ViewBuilder        // 없으면 Function declares an opaque return type ... error 발생
    func noteDetailRow(_ noteDetail: NoteDetail) -> some View {
        if noteDetail.isMemorized && itemControl.hideMemorized {
            EmptyView()
        }
        else {
            HStack {
                ForEach(0 ..< 2) { col in
                    noteDetailCell(noteDetail, TextFieldType(rawValue: col) ?? .term)
                        .onTapGesture {
                            itemLocation = ItemLocation(noteDetail.order, col)  // col 할당 관련해서, 여기 있으면 Keyboard 뒤에 View가 안 없어지는 경우 생김
                            if isEditMode { scrollTarget = noteDetail.order }
                        }
                }
                
                Button(action: {
                    if editMode == .active {
                        CustomUITextField(location: $itemLocation, closeKeyboard: $closeKeyboard).done(button: UIBarButtonItem())
                        scrollTarget = noteDetail.order
                    }
                    changeMemorizedState(id: noteDetail.id)
                    closeKeyboard = true            // 없으면 키보드 잔상 남음
                }) {
                    noteDetail.isMemorized == true ? Image(systemName: "checkmark.square.fill").imageScale(.large) : Image(systemName: "square").imageScale(.large)
                }
                .buttonStyle(PlainButtonStyle())        // TextField 상태일 때, 경계부분 누르면 버튼이 눌리는 현상 막기 위해
            }
            .padding()
            .modifier(ListModifier(verticalPadding: -5))
        }
    }
    
    func noteDetailCell(_ noteDetail: NoteDetail, _ selectedCol: TextFieldType) -> some View {
        return ZStack {
            switch selectedCol {
            case .term:
                if isEditMode == false {
                    noteDetailText(noteDetail.term, bodyColor: .textBodyColor, strokeColor: .tScreenColor)
                    GeometryReader { geometry in
                        HStack {
                            noteDetailScreen(noteDetail.order, geometry.size.width, .tScreenColor, itemControl.screen.left, anchor: .leading)
                        }
                    }
                }
                else {
                    NoteDetailTextField("Term", $note.term[noteDetail.order], ItemLocation(noteDetail.order, 0), bodyColor: .textFieldBodyColor, strokeColor: .tTextFieldStrokeColor)
                }
            case .definition:
                if isEditMode == false {
                    noteDetailText(noteDetail.definition, bodyColor: .textBodyColor, strokeColor: .dScreenColor)
                    GeometryReader { geometry in
                        HStack {
                            Spacer()
                            noteDetailScreen(noteDetail.order, geometry.size.width, .dScreenColor, itemControl.screen.right, anchor: .trailing)     // 여기는 + 1 안함
                        }
                    }
                }
                else {
                    NoteDetailTextField("Definition", $note.definition[noteDetail.order], ItemLocation(noteDetail.order, 1), bodyColor: .textFieldBodyColor, strokeColor: .dTextFieldStrokeColor)
                }
            }
        }
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
    
    func NoteDetailTextField(_ title: String, _ text: Binding<String>, _ itemLocation: ItemLocation, bodyColor: Color, strokeColor: Color) -> some View {
        // Keyboard Toolbar에서 열간 이동하기 위해 isFirstResponder 필요
        return CustomTextFieldWithToolbar(title: title, text: text, location: $itemLocation, isEnabled: $isEditMode, closeKeyboard: $closeKeyboard, col: itemLocation.col, isFirstResponder: self.itemLocation == itemLocation)
            .padding(.horizontal)
            .modifier(NoteDetailListModifier(bodyColor: bodyColor, strokeColor: strokeColor, lineWidth: 1.0))
    }
    
    func noteDetailScreen(_ order: Int, initalWidth: CGFloat = 4.0, _ stretchedWidth: CGFloat, _ screenColor: Color, _ isScreen: Bool, anchor: UnitPoint) -> some View {
        Rectangle()
            .foregroundColor(screenColor)
            .frame(width: initalWidth)
            .scaleEffect(x: isScreen && !tmpNoteDetails[order].isScaled ? stretchedWidth / initalWidth : 1.0, y: 1.0, anchor: anchor)
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
    
    var spacer: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) { Spacer() }
    }
    
    func showingButton(_ column: TextFieldType) -> some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        isDisableds[1].toggle()
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


// MARK: - Other Functions
extension NoteDetailView {
    func copyNoteDetails() {
        tmpNoteDetails = [NoteDetail]()
        
        Array(0 ..< note.itemCount).forEach { tmpNoteDetails.append(NoteDetail(order: $0, note.findItem(at: $0))) }
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
    
    func deleteMemorized() -> Void {      // TextField를 없애면 에러 발생
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
            saveContext()
            
            Array(0 ..< note.itemCount).forEach { tmpNoteDetails[$0].order = $0 }
            
            selection = Set<UUID>()
        }
    }
    
    func deleteItem(atOffsets offsets: IndexSet) {         // edit 상태에서 마지막꺼 지우면 에러 발생
        note.removeItem(atOffsets: offsets)
        tmpNoteDetails.remove(atOffsets: offsets)
        saveContext()
        
        Array(0 ..< note.itemCount).forEach { tmpNoteDetails[$0].order = $0 }
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

