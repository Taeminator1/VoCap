//
//  HomeView.swift
//  VoCap
//
//  Created by 윤태민 on 12/2/20.
//

//  Initial screen of the App:
//  - Add Note
//      - Press Add Note button on the top.
//  - Edit Note
//      - Press Edit button on the right of the navigation bar and press note you want to edit.
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
    
    @State private var isMakeNotePresented: Bool = true
    @State private var isEditMode: EditMode = .inactive
    @State private var noteRowOrder: Int?                               // Optional type to tell functions, make or edit.
    @State private var hideNoteDetailsNumber: Bool = false
    
    @State private var isSettingsPresented: Bool = false
    @State private var tipControls: [TipControl] = [TipControl(.tip0), TipControl(.tip1)]
    
    var body: some View {
        ZStack {
            NavigationView {
                List {
                    AddNoteButton(isPresent: $isMakeNotePresented, isEditMode: $isEditMode)
                    
                    ForEach(notes) {
                        NoteButton(isEditMode: $isEditMode, order: $noteRowOrder, isPresented: $isMakeNotePresented, tipControls: $tipControls, hideNumber: $hideNoteDetailsNumber, note: $0)
                    }
                    .onDelete(perform: deleteNote)
                    .onMove(perform: moteNote)
                }
                .navigationBarTitle("VoCap", displayMode: .inline)
                .sheet(isPresented: $isMakeNotePresented) {
                    let tmpNote = noteRowOrder == nil ? TmpNote() : TmpNote(note: notes[noteRowOrder!])
                    MakeNoteView(note: tmpNote, order: $noteRowOrder, isPresented: $isMakeNotePresented) { tmpNote in
                        self.noteRowOrder == nil ? self.addNote(tmpNote) : self.editNote(tmpNote)
                        self.isMakeNotePresented = false
                    }
                }
                .toolbar {
                    // NavigationBar
                    TestButton(placement: .navigationBarLeading) { notes.forEach { print($0.order) } }
                    editButton
                    
                    // BottomBar
                    Separator(placement: .bottomBar)
                    settingsButton
                }
                .ignoresSafeArea(.keyboard)                     // NoteDetailView에서의 키보드 잔상 없애기 위해
                .animation(.default)                            // 해당 자리에 있어야 함
                .listStyle(PlainListStyle())                    // title bar button 초기 색 변경 방지
                .environment(\.editMode, self.$isEditMode)      // 없으면 Edit 오류 생김(해당 위치에 있어야 함)
            }
            .navigationViewStyle(StackNavigationViewStyle())    // View전환할 때마다 Tool Bar 로딩 시간 없애기 위해
            .onAppear() {
                isMakeNotePresented = false                     // Toggle 시켜주지 않으면, 최초에 저장된 값 못 불러옴
                UITableView.appearance().showsVerticalScrollIndicator = false
            }
            .sheet(isPresented: $isSettingsPresented) {
                SettingsView(isSettingsPresented: $isSettingsPresented, tipControls: $tipControls)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
            
            ForEach(0 ..< tipControls.count) { TipView(tiptype: TipType(rawValue: $0)!, tipControls: $tipControls) }
        }
        .accentColor(.mainColor)
    }
}

// MARK: - Toolbar Items
private extension HomeView {
    var editButton: some ToolbarContent {
        EditButton(placement: .navigationBarTrailing, isEditMode: $isEditMode) {
            isEditMode.toggle()
            hideNoteDetailsNumber = isEditMode == .inactive ? false : true
        }
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

// MARK: - Modify Note rows
private extension HomeView {
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
    
    func makeOrder() {
        viewContext.saveContext()
        Array(0 ..< notes.count).forEach { notes[$0].order = Int16($0) }
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
