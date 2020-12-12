//
//  Note.swift
//  VoCap
//
//  Created by 윤태민 on 12/7/20.
//

import Foundation
import SwiftUI

struct Note: Codable, Identifiable {
    var id = UUID()
    var title: String = ""
    var colorIndex: Int = 0
    var isMemorized: Bool = false
    var isInWidget: Bool = false
    var memorizedNumber: Int = 0
    var totalNumber: Int = 0
    var notes: String = ""
}

struct AddNote {
    var title: String = "Add Note"
    var color: Color = Color.clear
}
