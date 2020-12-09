//
//  HomeView.swift
//  VoCap
//
//  Created by 윤태민 on 12/2/20.
//

import SwiftUI

struct HomeView: View {
//    @State private var word: String = ""
    @State private var showingAddNoteView: Bool = false
    
    var body: some View {
        ScrollView {            // To remove separator
            LazyVStack() {
                Button(action: { self.showingAddNoteView.toggle() }) {
                    AddNoteRow(note: Note())
                }
                .sheet(isPresented: $showingAddNoteView, content: {
                    AddNoteView()
                })
                
//                ForEach(0..<10) {
//                    NavigationLink(destination: Text("\($0)")) {
//                        NoteRow(note: Note(title: "Architecture", color: Color.yellow, memorizedNumber: 5, totalNumber: 121))
//                    }
//                }
            }
        }
        NavigationLink(destination: Text("d")) {
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
