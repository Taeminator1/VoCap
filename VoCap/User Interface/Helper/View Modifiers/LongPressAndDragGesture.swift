//
//  LongPressAndDragGesture.swift
//  VoCap
//
//  Created by 윤태민 on 9/21/21.
//

//  Define actions on process for long pressing and dragging.
//  - Basic:
//      - Touch down and up.
//  - Long Press:
//      - On the former place in specific duration.
//  - Drag:
//      - After specific duration, move the position.

import SwiftUI

struct LongPressAndDragGesture: ViewModifier {
    @Binding var isPressed: Bool
    
    var minimumDuration: Double = 0.2
    var action: () -> Void                      // Action for touching up and down.
    var dragAction: () -> Void                  // Action after dragging and before action.
    var longPressAction: () -> Void             // Action after pressing long and after action.
    
    func body(content: Content) -> some View {
        let dragGesture = DragGesture()
            .onEnded { _ in dragAction() }
        
        return content
            .gesture(dragGesture)
            .onLongPressGesture(minimumDuration: minimumDuration,
                                pressing: { pressing in
                                    isPressed = pressing
                                    action()
                                }) {
                longPressAction()
            }
    }
}

extension View {
    func onLongPressAndDragGesture(_ isPressed: Binding<Bool>, minimumDuration: Double = 0.2, action: @escaping () -> Void = { }, dragAction: @escaping () -> Void = { }, logPressAciton: @escaping () -> Void = { }) -> some View {
        self
            .modifier(LongPressAndDragGesture(isPressed: isPressed, action: action, dragAction: dragAction, longPressAction: logPressAciton))
    }
}
