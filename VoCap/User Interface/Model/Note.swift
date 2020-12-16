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
    
    var isWidget: Bool = true
    var isAutoCheck: Bool = true
}

struct AddNote {
    let title: String = "Add Note"
}
