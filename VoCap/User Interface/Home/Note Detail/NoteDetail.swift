//
//  TmpNoteDetail.swift
//  VoCap
//
//  Created by 윤태민 on 1/3/21.
//

//  Each item of Note

import Foundation
import SwiftUI

struct NoteDetail: Identifiable {
    var id: UUID = UUID()                   // Shuffle 해도 변하지 않음 -> Delete시 갱신안하게 하기 위함
    var order: Int = -1                     // NoteDetail의 List에 나오는 순서
    var isScaled: Bool = false              // 각 item의 Scale 여부 확인
    var term: String = ""
    var definition: String = ""
    var isMemorized: Bool = false

    init(order: Int, _ term: String, _ definition: String) {
        self.order = order
        self.term = term
        self.definition = definition
    }
    
    init(order: Int, _ item: (term: String, definition: String, isMemorized: Bool)) {
        self.order = order
        self.term = item.term
        self.definition = item.definition
        self.isMemorized = item.isMemorized
    }
}
