//
//  CustomGesture.swift
//  VoCap
//
//  Created by 윤태민 on 1/13/21.
//

import SwiftUI

struct CustomGestureModifier: ViewModifier {
    @Binding var isPressed: Bool
    
    let f: () -> Void
    
    func body(content: Content) -> some View {
        let dragGesture = DragGesture()
//            .onEnded({ _ in
//                print("Draged")
//                isPressed = false
//            })
        
//        let longPressGesture = LongPressGesture(minimumDuration: 0)
//            .onEnded({ _ in
//                print("Long Pressed")
//                isPressed = false
//            })
        
        return content
            .gesture(dragGesture)
            .onLongPressGesture(minimumDuration: 0,
                                pressing: { pressing in
                                    print(pressing)
                                    isPressed = pressing
                                    f()
                                },
                                perform: {
//                                    print("Long Pressed")
//                                    isPressed = false
                                })
    }
}

struct CustomGestureModifierExample: View {
    @State var isPressed = false
    @Namespace var namespace
    var body: some View {
        VStack(alignment: .trailing) {
            Text("Custom Gesture")
                .modifier(CustomGestureModifier(isPressed: $isPressed, f: { print("dd") }))
            
            if isPressed == true {
                Text("TRUE")
            }
            else {
                Text("FALSE")
            }
            
            if isPressed {
                Rectangle()
                    .foregroundColor(.blue)
                    .matchedGeometryEffect(id: "abc", in: namespace)
                    .animation(.default)
                    .frame(maxWidth: 10, maxHeight: 40)
                    .modifier(CustomGestureModifier(isPressed: $isPressed, f: {
                    }))
            }
            else {
                Rectangle()
                    .foregroundColor(.blue)
                    .matchedGeometryEffect(id: "abc", in: namespace)
                    .animation(.default)
                    .frame(maxWidth: 100, maxHeight: 40)
                    .modifier(CustomGestureModifier(isPressed: $isPressed, f: {
                    }))
            }
            
            Button(action: { isPressed.toggle() }) {
                Text("Toggle")
            }
            .padding()
        }
    }
}
