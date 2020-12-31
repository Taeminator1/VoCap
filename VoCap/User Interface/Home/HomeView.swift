//
//  HomeView.swift
//  VoCap
//
//  Created by 윤태민 on 12/2/20.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.order, ascending: true)],
        animation: .default)
    private var notes: FetchedResults<Note>
    
    @State private var isAddNotePresented: Bool = false
    @State private var isEditNotePresented: Bool = false
    @State private var isEditMode: EditMode = .inactive
    @State private var noteRowSelection: UUID?
    @State private var noteRowOrder: Int = 0
    
    @State private var showEddition: Bool = false
    @State private var showSettings: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                Button(action: { self.isAddNotePresented = true }) {
                    AddNoteRow()
                }
                .buttonStyle(BorderlessButtonStyle())
                .disabled(isEditMode == .inactive ? false : true)
                .sheet(isPresented: $isAddNotePresented) {
                    let tmpNote = TmpNote()
                    MakeNoteView(note: tmpNote, dNote: tmpNote, isAddNotePresented: $isAddNotePresented, isEditNotePresented: $isEditNotePresented) { title, colorIndex, memo in
                        self.addNote(title: title, colorIndex: colorIndex, memo: memo)
                        self.isAddNotePresented = false
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .listRowInsets(EdgeInsets())
                .background(Color(UIColor.systemBackground))
                
                ForEach(notes) { note in
                    HStack {
                        Button(action: {
                            if isEditMode == .inactive || isEditMode == .transient {    // When Edit Button is not pressed
                                self.noteRowSelection = note.id         // 왜 noteRowSelection에 !붙일 때랑 안 붙일 때 다르지?
                            }
                            else {                          // When Edit Button is pressed by user
                                self.noteRowOrder = Int(note.order)
                                self.isEditNotePresented = true
                            }
                        }) {
                            VStack(alignment: .leading) {
                                NoteRow(title: note.title!, colorIndex: note.colorIndex, totalNumber: note.totalNumber, memorizedNumber: note.memorizedNumber)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: NoteDetail(title: note.title), tag: note.id!, selection: $noteRowSelection) {
                            EmptyView()
                        }
                        .frame(width: 0).hidden()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .listRowInsets(EdgeInsets())
                    .background(Color(UIColor.systemBackground))
                }
                .onDelete(perform: deleteItems)
                .onMove(perform: moveItems)
            }
            .listStyle(PlainListStyle())                        // 안해주면 Add Note 누를 때, title bar button 초기 색이 하얗게 됨
            .navigationBarTitle("VoCap", displayMode: .inline)
            .sheet(isPresented: $isEditNotePresented) {
                MakeNoteView(note: TmpNote(note: notes[noteRowOrder]), dNote: TmpNote(note: notes[noteRowOrder]), isAddNotePresented: $isAddNotePresented, isEditNotePresented: $isEditNotePresented) { title, colorIndex, memo in
                    self.editItems(title: title, colorIndex: colorIndex, memo: memo)
                    self.isEditNotePresented = false
                }
            }
            .background(NavigationLink(destination: UtilityView(), isActive: $showEddition) { EmptyView() })
            .background(NavigationLink(destination: SettingsView(), isActive: $showSettings) { EmptyView() })
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    leadingItem
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Button(action: { showEddition = true }) {
                        Image(systemName: "plus.circle").imageScale(.large)
                    }
                }
                    
                ToolbarItem(placement: .bottomBar) { Spacer() }
                
                ToolbarItem(placement: .bottomBar) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape").imageScale(.large)
                    }
                }
            }
            .environment(\.editMode, self.$isEditMode)          // 없으면 Edit 오류 생김(해당 위치에 있어야 함)
        }
        .navigationViewStyle(StackNavigationViewStyle())                // 없으면 View전환할 때마다 Tool Bar 로딩되는데 시간이 걸림
    }
}

// MARK: - Preivew
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewDevice("iPhone SE (2nd generation)")
//        HomeView()
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//            .previewDevice("iPhone 12 Pro")
//            .preferredColorScheme(.dark)
    }
}

// MARK: - Navigation Bar Items
private extension HomeView {
    var leadingItem: some View {
        NavigationLink(destination: SearchView()) {
            Image(systemName: "magnifyingglass").imageScale(.large)
        }
    }
    
    private func editItems(title: String, colorIndex: Int16, memo: String) {
        notes[noteRowOrder].title = title
        notes[noteRowOrder].colorIndex = colorIndex
        notes[noteRowOrder].memo = memo
        
        saveContext()
    }
}

// MARK: - Items
private extension HomeView {
    private func addNote(title: String, colorIndex: Int16, memo: String) {
        withAnimation {
            let newNote = Note(context: viewContext)
            newNote.id = UUID()
            newNote.title = title
            newNote.colorIndex = colorIndex
            newNote.memo = memo

            saveContext()
            makeOrder()             // 간단하게 바꿔도 될 듯
            saveContext()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { notes[$0] }.forEach(viewContext.delete)

            saveContext()
            makeOrder()
            saveContext()
        }
    }
    
    private func moveItems(from source: IndexSet, to destination: Int) {
        withAnimation {
            arrangeOrder(start: source.map({$0}).first!, destination: destination)
            saveContext()
        }
    }
}

// MARK: - Other Functions
private extension HomeView {
    
    func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func makeOrder() {
        for i in 0..<notes.count {
            notes[i].order = Int16(i)
        }
    }
    
    func arrangeOrder(start: Int, destination: Int) {
        if start == destination { return }
        
        if start < destination {
            for i in start..<destination {
                notes[i].order -= 1
            }
        }
        else {
            for i in destination..<start {
                notes[i].order += 1
            }
        }
        notes[start].order = Int16(destination - 1)
    }
}
