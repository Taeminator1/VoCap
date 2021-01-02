//
//  MakeNoteView2.swift
//  VoCap
//
//  Created by 윤태민 on 12/28/20.
//

import SwiftUI

struct TmpNote {
    var colorIndex: Int
    var isAutoCheck: Bool
    var isWidget: Bool
    var memo: String
    var title: String
    
    init() {
        self.colorIndex = Int.random(in: 0..<myColor.colors.count)       // Int16으로 선언하면 Picker에서 오류 발생
        self.isAutoCheck = false
        self.isWidget = false
        self.memo = ""
        self.title = self.memo
    }
    
    init(note: Note) {
        self.colorIndex = Int(note.colorIndex)
        self.isAutoCheck = note.isAutoCheck
        self.isWidget = note.isWidget
        self.memo = note.memo!
        self.title = note.title!
    }
    
    func isEqual(_ note: TmpNote) -> Bool {
        if colorIndex == note.colorIndex &&
            isAutoCheck == note.isAutoCheck &&
            isWidget == note.isWidget &&
            memo == note.memo &&
            title == note.title {
            return true
        }
        else {
            return false
        }
    }
}