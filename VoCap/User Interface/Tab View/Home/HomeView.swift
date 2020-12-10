//
//  HomeView.swift
//  VoCap
//
//  Created by 윤태민 on 12/2/20.
//

import SwiftUI

struct HomeView: View {
    @State private var showingAddNoteView: Bool = false
    
    @ObservedObject var noteStore = NoteStore()
    
    var body: some View {
        ScrollView {            // To remove separator
            LazyVStack() {
                Button(action: { self.showingAddNoteView.toggle() }) {
                    AddNoteRow(addNote: AddNote())
                }
                .sheet(isPresented: $showingAddNoteView, content: {
                    AddNoteView(noteStore: self.noteStore, showingAddNoteView: $showingAddNoteView)
                })
                
                ForEach(noteStore.notes) { note in
                    NavigationLink(destination: Text("abc")) {
                        NoteRow(note: note)
                    }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
