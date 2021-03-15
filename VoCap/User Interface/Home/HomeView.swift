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
    
    @State private var isAddNotePresented: Bool = false
    @State private var isEditNotePresented: Bool = true         // 처음 실행할 때 MakeNoteView의 isEditNotePresented를 true로 변경해서 sheet를 띄우고 닫아야(NavigationView.onAppear()) 처음에 Edit시 note 가리키지 못하는 현상 막을 수 있음
    @State private var isEditMode: EditMode = .inactive
    @State private var noteRowSelection: UUID?
    @State private var noteRowOrder: Int!
    
    @State private var showUtility: Bool = false
    @State private var showTest: Bool = false
    
    @State private var isSettingsPresented: Bool = false
    
    @State var hideNoteDetailsNumber: Bool = false
    
    @State var isDisableds: [Bool] = [false, false]
    @State var isHowToAddItem: Bool = UserDefaults.standard.bool(forKey: "Tip0")
    @State var isHowToGlanceItem: Bool = UserDefaults.standard.bool(forKey: "Tip1")
    
    var body: some View {
        ZStack {
            NavigationView {
                List {
                    Button(action: { self.isAddNotePresented = true }) { AddNoteRow() }
                    .disabled(isEditMode == .inactive ? false : true)
                    .sheet(isPresented: $isAddNotePresented) {
                        let tmpNote = TmpNote()
                        
                        XxMakeNoteView(note: tmpNote, dNote: tmpNote, isAddNotePresented: $isAddNotePresented, isEditNotePresented: $isEditNotePresented) { title, colorIndex, isWidget, isAutoCheck, memo in
                            self.addNote(title, colorIndex, isWidget, isAutoCheck, memo)
                            self.isAddNotePresented = false
                            self.isEditNotePresented = false
                        }
                    }
                    .modifier(HomeViewNoteRowModifier())
                    .buttonStyle(BorderlessButtonStyle())
                    
                    ForEach(notes) { note in
                        HStack {
                            Button(action: {
                                if isEditMode == .inactive || isEditMode == .transient {    // When Edit Button has been not pressed
                                    self.noteRowSelection = note.id                         // 왜 noteRowSelection에 !붙일 때랑 안 붙일 때 다르지?
                                }
                                else {                                                      // When Edit Button has been pressed by user
                                    self.noteRowOrder = Int(note.order)
                                    self.isEditNotePresented = true
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
                        .modifier(HomeViewNoteRowModifier())
                        .buttonStyle(PlainButtonStyle())            // .active 상태 일 때 버튼 눌릴 수 있도록 함
                    }
                    .onDelete(perform: deleteItems)
                    .onMove(perform: moveItems)
                }
    //            .ignoresSafeArea(.keyboard)
                .animation(.default)                    // 해당 자리에 있어야 함
                .listStyle(PlainListStyle())                        // 안해주면 Add Note 누를 때, title bar button 초기 색이 하얗게 됨
                .navigationBarTitle("VoCap", displayMode: .inline)
                .sheet(isPresented: $isEditNotePresented) {
                    if let order = noteRowOrder {
                        let tmpNote = TmpNote(note: notes[order])
                       
                        XxMakeNoteView(note: tmpNote, dNote: tmpNote, isAddNotePresented: $isAddNotePresented, isEditNotePresented: $isEditNotePresented) { title, colorIndex, isWidget, isAutoCheck, memo in
                            self.editItems(title, colorIndex, isWidget, isAutoCheck, memo)
                            self.isEditNotePresented = false
                            self.isEditNotePresented = false
                        }
                    }
                }
//                .background(NavigationLink(destination: UtilityView(), isActive: $showUtility) { EmptyView() })
//                .background(NavigationLink(destination: TestView(), isActive: $showTest) { TestView() })
                .toolbar {
//                    ToolbarItem(placement: .navigationBarLeading) { leadingItem }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                            .onAppear() {
                                if isEditMode == .inactive || isEditMode == .transient {    // When Edit Button has been not pressed
                                    hideNoteDetailsNumber = false
                                }
                                else {                                                      // When Edit Button has been pressed by user
                                    hideNoteDetailsNumber = true
                                }
                            }
                    }
                    
//                    ToolbarItem(placement: .bottomBar) { bottom1Item }
//                    ToolbarItem(placement: .bottomBar) { Spacer() }
//                    ToolbarItem(placement: .bottomBar) { bottom2Item }
                    ToolbarItem(placement: .bottomBar) { Spacer() }
                    ToolbarItem(placement: .bottomBar) { bottom3Item.disabled(isEditMode != .inactive) }
                }
                .environment(\.editMode, self.$isEditMode)          // 없으면 Edit 오류 생김(해당 위치에 있어야 함)
            }
            .navigationViewStyle(StackNavigationViewStyle())                // 없으면 View전환할 때마다 Tool Bar 로딩되는데 시간이 걸림
            .onAppear() { isEditNotePresented = false }
            .sheet(isPresented: $isSettingsPresented) {
                SettingsView(isSettingsPresented: $isSettingsPresented, isHowToAddItem: $isHowToAddItem, isHowToGlanceItem: $isHowToGlanceItem)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
            
            if isDisableds[0] && isHowToAddItem {
                Rectangle()
                    .fill(Color.black.opacity(0.4))
                    .ignoresSafeArea()
                    .overlay(
                        Button(action: {
                            isDisableds[0].toggle()
                            isHowToAddItem.toggle()
                            UserDefaults.standard.set(self.isHowToAddItem, forKey: "Tip0")
                        }) {
                            HowToAddItemView()
                        }
                        .buttonStyle(PlainButtonStyle())
                    )
            }
            
            if isDisableds[1] && isHowToGlanceItem {
                Rectangle()
                    .fill(Color.black.opacity(0.4))
                    .ignoresSafeArea()
                    .overlay(
                        Button(action: {
                            isDisableds[1].toggle()
                            isHowToGlanceItem.toggle()
                            UserDefaults.standard.set(self.isHowToGlanceItem, forKey: "Tip1")
                        }) {
                            HowToGlanceItemView()
                        }
                        .buttonStyle(PlainButtonStyle())
                    )
            }
        }
        .accentColor(.mainColor)
    }
}


// MARK: - Tool Bar Items
private extension HomeView {
    var leadingItem: some View {
        NavigationLink(destination: SearchView()) {
            Image(systemName: "magnifyingglass").imageScale(.large)
        }
    }
    
    private func editItems(title: String, colorIndex: Int16, memo: String) {
        notes[noteRowOrder!].title = title
        notes[noteRowOrder!].colorIndex = colorIndex
        notes[noteRowOrder!].memo = memo
        
        saveContext()
    }
    
    private func editItems(_ title: String, _ colorIndex: Int16, _ isWidget: Bool, _ isAutoCheck: Bool, _ memo: String) {
        notes[noteRowOrder!].title = title
        notes[noteRowOrder!].colorIndex = colorIndex
        notes[noteRowOrder!].isWidget = isWidget
        notes[noteRowOrder!].isAutoCheck = isAutoCheck
        notes[noteRowOrder!].memo = memo
        
        saveContext()
    }
    
    var bottom1Item: some View {
        Button(action: { showUtility = true }) {
            Image(systemName: "1.circle").imageScale(.large)
        }
    }
    
    var bottom2Item: some View {
        Button(action: { showTest = true }) {
            Image(systemName: "2.circle").imageScale(.large)
        }
    }
    
    var bottom3Item: some View {
        Button(action: { isSettingsPresented = true }) {
            Image(systemName: "gearshape").imageScale(.large)
        }
    }
}

// MARK: - Modify NoteRows
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
    
    private func addNote(_ title: String, _ colorIndex: Int16, _ isWidget: Bool, _ isAutoCheck: Bool, _ memo: String) {
        withAnimation {
            let newNote = Note(context: viewContext)
            newNote.id = UUID()
            newNote.title = title
            newNote.colorIndex = colorIndex
            newNote.isWidget = isWidget
            newNote.isAutoCheck = isAutoCheck
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
private extension HomeView {
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
