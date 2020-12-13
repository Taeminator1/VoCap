//
//  NoteDetail.swift
//  VoCap
//
//  Created by 윤태민 on 12/9/20.
//

import SwiftUI

struct NoteDetail: View {
    
    let selectedNote: Note
    
    var body: some View {
        Text("\(selectedNote.title)")
    }
}

struct NoteDetail_Previews: PreviewProvider {
    static var previews: some View {
        NoteDetail(selectedNote: Note())
    }
}
