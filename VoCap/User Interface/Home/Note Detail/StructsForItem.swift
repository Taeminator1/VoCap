//
//  StructsForItem.swift
//  VoCap
//
//  Created by 윤태민 on 7/31/21.
//

import Foundation

struct ItemControl {
    var lScreen: Bool = false       // left Screen
    var rScreen: Bool = false       // right Screen
    var isShuffled: Bool = false
    var hideMemorized: Bool = false
}

struct ItemAnimation {
    var isTermScaled: Bool = false
    var isDefScaled: Bool = false
    var isScaledArray: [Bool] = []
    
    mutating func append(_ bool: Bool) {
        isScaledArray.append(bool)
    }
}
