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
    
    @State var noteRowOrder: Int16 = 0
    
    var body: some View {
        NavigationView {
            List {
                Button(action: { self.isAddNotePresented.toggle() }) {
                    AddNoteRow()
                }
                .buttonStyle(BorderlessButtonStyle())
                .disabled(makeEddNoteDisabled())
                .sheet(isPresented: $isAddNotePresented) {
                    AddNoteView(isAddNotePresented: $isAddNotePresented) { title, colorIndex, memo in
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
                                self.noteRowOrder = note.order
                                self.isEditNotePresented.toggle()
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
            .navigationBarItems(leading: leadingItem, trailing: EditButton())
            .navigationBarTitle("Taemin", displayMode: .inline)
            .environment(\.editMode, self.$isEditMode)          // 없으면 Edit 오류 생김(해당 위치에 있어야 함)
            .sheet(isPresented: $isEditNotePresented) {
                EditNoteView(title: notes[Int(noteRowOrder)].title!, colorIndex: Int(notes[Int(noteRowOrder)].colorIndex), memo: notes[Int(noteRowOrder)].memo!, isEditNotePresented: $isEditNotePresented) { title, colorIndex, memo in
                    self.editItems(title: title, colorIndex: colorIndex, memo: memo)
                    self.isEditNotePresented = false
                }
            }
        }
    }
    func makeEddNoteDisabled() -> Bool {
        if isEditMode == .inactive {
            return false
        }
        else {
            return true
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewDevice("iPhone 11 Pro")
//            .previewDevice("iPhone SE (2nd generation)")
        HomeView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .preferredColorScheme(.dark)
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
        notes[Int(noteRowOrder)].title = title
        notes[Int(noteRowOrder)].colorIndex = colorIndex
        notes[Int(noteRowOrder)].memo = memo
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
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

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            
            for i in 0..<notes.count {
                notes[i].order = Int16(i)
            }
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { notes[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            
            for i in 0..<notes.count {
                notes[i].order = Int16(i)
            }
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func moveItems(from source: IndexSet, to destination: Int) {
        withAnimation {
            let start = source.map({$0}).first!
            
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
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
