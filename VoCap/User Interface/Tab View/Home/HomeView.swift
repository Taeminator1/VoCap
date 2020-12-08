//
//  HomeView.swift
//  VoCap
//
//  Created by 윤태민 on 12/2/20.
//

import SwiftUI

struct HomeView: View {
    @State private var word: String = ""
    
    var body: some View {
        ScrollView {
            LazyVStack() {
                AddingNoteRow(note: Note())
                
                ForEach(0..<100) {_ in
                    NoteRow(note: Note(title: "Architecture", color: Color.yellow, memorizedNumber: 5, totalNumber: 121))
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
