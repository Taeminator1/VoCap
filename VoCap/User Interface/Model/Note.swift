//
//  Note.swift
//  VoCap
//
//  Created by 윤태민 on 12/7/20.
//

import Foundation
import SwiftUI

struct Note {
    var title: String
    var color: Color
    var isMemorized: Bool
    var isInWidget: Bool
    var memorizedNumber: Int
    var totalNumber: Int
    
    init() {
        self.title = "Add Note"
        self.color = Color.white
        self.isMemorized = false
        self.isInWidget = false
        self.memorizedNumber = 0
        self.totalNumber = 0
    }
    
    init(title: String, color: Color = Color.white, isMemorized: Bool = false, isInWidget: Bool = true, memorizedNumber: Int, totalNumber: Int) {
        self.title = title
        self.color = color
        self.isMemorized = isMemorized
        self.isInWidget = isInWidget
        self.memorizedNumber = memorizedNumber
        self.totalNumber = totalNumber
    }
}

struct AddingNote {
    var title: String
    
    init(title: String) {
        self.title = title
    }
}
