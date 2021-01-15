//
//  TmpNoteDetail.swift
//  VoCap
//
//  Created by 윤태민 on 1/3/21.
//

import Foundation
import SwiftUI

struct TmpNoteDetail: Identifiable {
    var id: UUID = UUID()                    // Shuffle 해도 변하지 않음 -> Delete시 갱신안하게 하기 위함
    var order: Int = -1                      // NoteDetail의 List에 나오는 순서
    var term: String = ""
    var definition: String = ""
    var isMemorized: Bool = false
}
