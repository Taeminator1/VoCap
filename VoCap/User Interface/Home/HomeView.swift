//
//  HomeView.swift
//  VoCap
//
//  Created by 윤태민 on 12/2/20.
//

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
    
    @State var hideNoteDetailsNumber: Bool = false
    
    @State var isDisableds: [Bool] = [false, false]
    @State var isTipsPresented: [Bool] = [UserDefaults.standard.bool(forKey: "Tip0"), UserDefaults.standard.bool(forKey: "Tip1")]
    
    var body: some View {
        ZStack {
            NavigationView {
                List {
                    AddNoteButton(isPresent: $isMakeNotePresented, isEditMode: $isEditMode)
                    
                    ForEach(notes) {
                        noteList($0)
//                        NoteButton(isPresented: $isMakeNotePresented, isEditMode: $isEditMode, id: $noteRowSelection, order: $noteRowOrder, hideNumber: $hideNoteDetailsNumber, isDisableds: $isDisableds, note: $0)
                    }
                    .onDelete(perform: deleteItems)
                    .onMove(perform: moveItems)
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
                SettingsView(isSettingsPresented: $isSettingsPresented, isTipsPresented: $isTipsPresented)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
            
            ForEach(0 ..< isTipsPresented.count) {
                TipView(isDisableds: $isDisableds, isPresenteds: $isTipsPresented, order: $0)
            }
        }
        .accentColor(.mainColor)
    }
}

// MARK: - Note List
extension HomeView {
    func noteList(_ note: Note) -> some View {
        HStack {
            Button(action: {
                if isEditMode == .inactive || isEditMode == .transient {
                    self.noteRowSelection = note.id     // 왜 noteRowSelection에 !붙일 때랑 안 붙일 때 다르지?
                }
                else {
                    self.noteRowOrder = Int(note.order)
                    self.isMakeNotePresented = true
                }
            }) {
                VStack() {
                    NoteRow(title: note.title!, colorIndex: note.colorIndex, totalNumber: Int16(note.term.count), memorizedNumber: Int16(countTrues(note.isMemorized)), hideNoteDetailsNumber: $hideNoteDetailsNumber)
                }
            }
            
            NavigationLink(destination: NoteDetailView(note: note, isDisableds: $isDisableds), tag: note.id!, selection: $noteRowSelection) {
                EmptyView()
            }
            .frame(width: 0).hidden()
        }
        .listModifier()
        .buttonStyle(PlainButtonStyle())            // .active 상태 일 때 버튼 눌릴 수 있도록 함
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
private extension HomeView {
    func editNote(_ note: TmpNote) {
        notes[noteRowOrder!].title = note.title
        notes[noteRowOrder!].colorIndex = Int16(note.colorIndex)
        notes[noteRowOrder!].isWidget = note.isWidget
        notes[noteRowOrder!].isAutoCheck = note.isAutoCheck
        notes[noteRowOrder!].memo = note.memo
        
        saveContext()
    }
    
    func addNote(_ note: TmpNote) {
        withAnimation {
            let newNote = Note(context: viewContext)
            newNote.id = UUID()
            newNote.title = note.title
            newNote.colorIndex = Int16(note.colorIndex)
            newNote.isWidget = note.isWidget
            newNote.isAutoCheck = note.isAutoCheck
            newNote.memo = note.memo

            saveContext()
            makeOrder()             // 간단하게 바꿔도 될 듯
            saveContext()
        }
    }

    func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { notes[$0] }.forEach(viewContext.delete)

            saveContext()
            makeOrder()
            saveContext()
        }
    }
    
    func moveItems(from source: IndexSet, to destination: Int) {
        withAnimation {
            arrangeOrder(start: source.map({$0}).first!, destination: destination)
            saveContext()
        }
    }
    
    func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

// MARK: - Other Functions
extension HomeView {
    func makeOrder() {
        for i in 0..<notes.count {
            notes[i].order = Int16(i)
        }
    }
    
    func arrangeOrder(start: Int, destination: Int) {
        if start == destination { return }
        
        if start < destination {
            for i in (start + 1)..<destination {
                notes[i].order -= 1
            }
            notes[start].order = Int16(destination - 1)
        }
        else {
            for i in destination..<start {
                notes[i].order += 1
            }
            notes[start].order = Int16(destination)
        }
        
    }
    
    func countTrues(_ arr: [Bool]) -> Int {
        var result: Int = 0
        for i in 0..<arr.count {
            if arr[i] { result += 1 }
        }
        return result
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
