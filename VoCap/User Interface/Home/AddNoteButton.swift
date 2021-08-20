//
//  AddNoteButton.swift
//  VoCap
//
//  Created by 윤태민 on 7/30/21.
//

import SwiftUI

struct AddNoteButton: View {
    @Binding var isPresent: Bool
    @Binding var isEditMode: EditMode
    
    var body: some View {
        Button(action: { isPresent = true }) { AddNoteRow() }
            .disabled(isEditMode == .inactive ? false : true)
            .modifier(HomeListModifier())
            .buttonStyle(BorderlessButtonStyle())
    }
}
