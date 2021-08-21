//
//  EditModeExtension.swift
//  VoCap
//
//  Created by 윤태민 on 8/21/21.
//

import SwiftUI

extension EditMode {
    mutating func toggle() {
        self = self == .active ? .inactive : .active
    }
}
