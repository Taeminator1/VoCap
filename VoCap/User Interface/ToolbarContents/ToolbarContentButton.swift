//
//  ToolbarContentButton.swift
//  VoCap
//
//  Created by 윤태민 on 8/7/21.
//

import SwiftUI

protocol ToolbarContentButton: ToolbarContent {
    var action: () -> Void { get }
}

struct DoneButton: ToolbarContentButton {
    var title: String = "Done"
    var isDisabled: Bool = false
    var action: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { action() }) {
                Text(title)
            }
            .disabled(isDisabled)
        }
    }
}

struct CancelButton: ToolbarContentButton {
    var action: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: { action() }) {
                Text("Cancel")
            }
        }
    }
}
