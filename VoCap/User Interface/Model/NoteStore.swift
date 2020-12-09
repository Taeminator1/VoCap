//
//  NoteStore.swift
//  VoCap
//
//  Created by 윤태민 on 12/9/20.
//

import Foundation

final class NoteStore: ObservableObject {
    @Published var notes: [Note]
    
    init (notes: [Note] = []) {
        self.notes = notes
    }
}
