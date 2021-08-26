//
//  StructsForItem.swift
//  VoCap
//
//  Created by 윤태민 on 7/31/21.
//

//  For state property to control item in note.
//  - Is it blocked?
//  - Is it shuffled?
//  - Is momorized items hide?

import Foundation
import SwiftUI

struct ItemControl {
    var screen = Phase()
    var isShuffled: Bool = false
    var hideMemorized: Bool = false
    
    var isScaled = Phase()

    struct Phase {
        var left: Bool = false
        var right: Bool = false
    }
    
    mutating func toggleLeft() {
        if screen.right == true {
            screen.right.toggle()
            isScaled.right.toggle()
        }
        screen.left.toggle()
        isScaled.left.toggle()
    }
    
    mutating func toggleRight() {
        if screen.left == true {
            screen.left.toggle()
            isScaled.left.toggle()
        }
        screen.right.toggle()
        isScaled.right.toggle()
    }
}
