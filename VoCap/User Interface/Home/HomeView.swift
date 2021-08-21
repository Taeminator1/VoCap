//
//  HomeView.swift
//  VoCap
//
//  Created by 윤태민 on 12/2/20.
//

//  Initial screen of the App:
//  - Add a new note.
//  - Edit a exiting note.
//  - Access each note.
//  - Settings

import SwiftUI
import CoreData

struct HomeView: View {
    let persistenceController = PersistenceController.shared
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.order, ascending: true)],
        animation: .default)
    private var notes: FetchedResults<Note>
    
    @State var isMakeNotePresented: Bool = true         // 처음 실행할 때 MakeNoteView의 isEditNotePresented를 true로 변경해서 sheet를 띄우고 닫아야(NavigationView.onAppear()) 처음에 Edit시 note 가리키지 못하는 현상 막을 수 있음
    @State var isEditMode: EditMode = .inactive
    @State var noteRowSelection: UUID?
    @State var noteRowOrder: Int?
    
    @State var isSettingsPresented: Bool = false
    @State var tipControls: [TipControl] = [TipControl(.tip0), TipControl(.tip1)]
    
    @State var hideNoteDetailsNumber: Bool = false
    
    var body: some View {
        ZStack {
            NavigationView {
                List {
                    AddNoteButton(isPresent: $isMakeNotePresented, isEditMode: $isEditMode)
                    
                    ForEach(notes) {
                        NoteButton(isPresented: $isMakeNotePresented, isEditMode: $isEditMode, id: $noteRowSelection, order: $noteRowOrder, hideNumber: $hideNoteDetailsNumber, tipControls: $tipControls, note: $0)
                    }
                    .onDelete(perform: deleteNote)
                    .onMove(perform: moteNote)
                }
                .ignoresSafeArea(.keyboard)             // NoteDetailView에서의 키보드 잔상 없어지게 하기 위해(Toolbar에는 잔상 생김)
                .animation(.default)                    // 해당 자리에 있어야 함
                .listStyle(PlainListStyle())                        // 안해주면 Add Note 누를 때, title bar button 초기 색이 하얗게 됨
                .navigationBarTitle("VoCap", displayMode: .inline)
                .sheet(isPresented: $isMakeNotePresented) {
                    let tmpNote = noteRowOrder == nil ? TmpNote() : TmpNote(note: notes[noteRowOrder!])
                    MakeNoteView(note: tmpNote, noteRowOrder: $noteRowOrder, isPresented: $isMakeNotePresented) { tmpNote in
                        self.noteRowOrder == nil ? self.addNote(tmpNote) : self.editNote(tmpNote)
                        self.isMakeNotePresented = false
                    }
                }
                .toolbar {
                    // NavigationBar
//                    TestButton() { notes.forEach { print($0.order) } }
                    editButton
                    
                    // BottomBar
                    spacer
                    settingsButton
                }
                .environment(\.editMode, self.$isEditMode)          // 없으면 Edit 오류 생김(해당 위치에 있어야 함)
            }
            .navigationViewStyle(StackNavigationViewStyle())        // 없으면 View전환할 때마다 Tool Bar 로딩되는데 시간이 걸림
            .onAppear() {
                isMakeNotePresented = false
                UITableView.appearance().showsVerticalScrollIndicator = false
            }
            .sheet(isPresented: $isSettingsPresented) {
                SettingsView(isSettingsPresented: $isSettingsPresented, tipControls: $tipControls)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
            
            ForEach(0 ..< tipControls.count) { TipView(order: $0, tipControls: $tipControls) }
        }
        .accentColor(.mainColor)
    }
}

// MARK: - Toolbar Items
extension HomeView {

    var editButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {                // localize 위해 EditButton() 안 씀
                if isEditMode == .inactive  { isEditMode = .active }
                else                        { isEditMode = .inactive }
            }) {
                if isEditMode == .inactive  { Text("Edit") }
                else                        { Text("Done") }
            }
            .onAppear() {
                if isEditMode == .inactive || isEditMode == .transient {    // When Edit Button has been not pressed
                    hideNoteDetailsNumber = false
                }
                else {                                                      // When Edit Button has been pressed by user
                    hideNoteDetailsNumber = true
                }
            }
        }
    }
    
    var spacer: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) { Spacer() }
    }
    
    var settingsButton: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Button(action: { isSettingsPresented = true }) {
                Image(systemName: "gearshape").imageScale(.large)
            }
            .disabled(isEditMode != .inactive)
        }
    }
}

// MARK: - Modify NoteRows
extension HomeView {
    func editNote(_ note: TmpNote) {
        notes[noteRowOrder!].assignNote(context: viewContext, tmpNote: note)
        viewContext.saveContext()
    }
    
    func addNote(_ note: TmpNote) {
        withAnimation {
            _ = Note(context: viewContext, tmpNote: note)
            makeOrder()
        }
    }

    func deleteNote(offsets: IndexSet) {
        withAnimation {
            offsets.map { notes[$0] }.forEach(viewContext.delete)
            makeOrder()
        }
    }
    
    func moteNote(from source: IndexSet, to destination: Int) {
        withAnimation {
            arrangeOrder(start: source.map({$0}).first!, end: destination)
        }
    }
}

// MARK: - Other Functions
extension HomeView {
    func makeOrder() {
        viewContext.saveContext()
        for i in 0..<notes.count {
            notes[i].order = Int16(i)
        }
        viewContext.saveContext()
    }
    
    func arrangeOrder(start: Int, end: Int) {
        if start == end { return }
        
        if start < end {
            for i in (start + 1) ..< end {
                notes[i].order -= 1
            }
            notes[start].order = Int16(end - 1)
        }
        else {
            for i in end ..< start {
                notes[i].order += 1
            }
            notes[start].order = Int16(end)
        }
        viewContext.saveContext()
    }
}


// MARK: - Preivew
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewDevice("iPhone XR")
//            .previewDevice("iPhone SE (2nd generation)")
//            .preferredColorScheme(.dark)
    }
}
