//
//  HomeView.swift
//  VoCap
//
//  Created by 윤태민 on 12/2/20.
//

import SwiftUI

struct HomeView: View {
    @State private var showingAddNoteView: Bool = false
    
    @ObservedObject var noteStore: NoteStore
    
    @State private var isEditMode: EditMode = .inactive
    @State private var noteRowSelection: UUID?
    
    var body: some View {
        
        NavigationView {
            List {
                Button(action: { self.showingAddNoteView.toggle() }) {
                    AddNoteRow(addNote: AddNote())
                }
                .buttonStyle(BorderlessButtonStyle())
                .sheet(isPresented: $showingAddNoteView, content: {
                    AddNoteView(noteStore: self.noteStore, showingAddNoteView: $showingAddNoteView)
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .listRowInsets(EdgeInsets())
                .background(Color(UIColor.systemBackground))
                
                
                ForEach(noteStore.notes) { note in
                    HStack {
                        Button(action: {
                            if isEditMode == .inactive {    // When Edit Button is not pressed
                                self.noteRowSelection = note.id         // 왜 noteRowSelection에 !붙일 때랑 안 붙일 때 다르지?
                            }
                            else {                          // When Edit Button is pressed
                                
                            }
                        }) {
                            NoteRow(note: note)
                        }
                        .buttonStyle(PlainButtonStyle())

                        NavigationLink(destination: NoteDetail(selectedNote: note), tag: note.id, selection: $noteRowSelection) {
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
            .listStyle(PlainListStyle())
            .navigationBarItems(leading: leadingItem, trailing: EditButton())
            .navigationBarTitle("VoCap", displayMode: .inline)
            .environment(\.editMode, self.$isEditMode)          // 없으면 Edit 오류 생김(해당 위치에 있어야 함)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(noteStore: NoteStore())
            .previewDevice("iPhone 11 Pro")
//            .previewDevice("iPhone SE (2nd generation)")
        HomeView(noteStore: NoteStore())
            .preferredColorScheme(.dark)
    }
}


// MARK: - Items
private extension HomeView {
    var leadingItem: some View {
        NavigationLink(destination: SearchView()) {
            Image(systemName: "magnifyingglass").imageScale(.large)
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        noteStore.notes.remove(atOffsets: offsets)
    }
    
    func moveItems(from source: IndexSet, to destination: Int) {
        noteStore.notes.move(fromOffsets: source, toOffset: destination)
    }
}
