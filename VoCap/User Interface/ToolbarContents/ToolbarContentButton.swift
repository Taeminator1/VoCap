//
//  ToolbarContentButton.swift
//  VoCap
//
//  Created by 윤태민 on 8/7/21.
//

import SwiftUI

protocol ToolbarContentButton: ToolbarContent {
    var placement: ToolbarItemPlacement { get }
    var action: () -> Void { get }
}

struct EditButton: ToolbarContentButton {
    var placement: ToolbarItemPlacement
    @Binding var isEditMode: EditMode
    
    var action: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            Button(action: { action() }) {
                if isEditMode == .inactive  { Text("Edit") }
                else                        { Text("Done") }
            }
        }
    }
}

struct DoneButton: ToolbarContentButton {
    var placement: ToolbarItemPlacement
    
    var title: String = "Done"
    var isDisabled: Bool = false
    var action: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            Button(action: { action() }) {
                Text(title)
            }
            .disabled(isDisabled)
        }
    }
}

struct CancelButton: ToolbarContentButton {
    var placement: ToolbarItemPlacement
    
    var action: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            Button(action: { action() }) {
                Text("Cancel")
            }
        }
    }
}

struct TestButton: ToolbarContentButton {
    var placement: ToolbarItemPlacement
    
    var action: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            Button(action: { action() }) {
                Text("Test")
            }
        }
    }
}

struct Separator: ToolbarContent {
    var placement: ToolbarItemPlacement

    var body: some ToolbarContent {
        ToolbarItem(placement: placement) { Spacer() }
    }
}
