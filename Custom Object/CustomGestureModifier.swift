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
            .onEnded({ _ in
//                print("Draged")
            })
        
        return content
            .gesture(dragGesture)
            .onLongPressGesture(minimumDuration: 0.2,
                                pressing: { pressing in
                                    isPressed = pressing
                                    f()
                                },
                                perform: {
//                                    print("Long Pressed")
                                })
            
    }
}

// MARK: - Example
//struct ContentView: View {
//    @State var isPressed = false
//    @Namespace var namespace
//    
//    @State var isLongPressing = false
//    
//    var body: some View {
//        VStack(alignment: .trailing) {
//            
//            if isPressed {
//                Rectangle()
//                    .foregroundColor(.blue)
//                    .matchedGeometryEffect(id: "abc", in: namespace)
//                    .animation(.default)
//                    .frame(maxWidth: 10, maxHeight: 40)
//                    .modifier(CustomGestureModifier(isPressed: $isPressed, f: { print("Completed") }))
//            }
//            else {
//                Rectangle()
//                    .foregroundColor(.blue)
//                    .matchedGeometryEffect(id: "abc", in: namespace)
//                    .animation(.default)
//                    .frame(maxWidth: 100, maxHeight: 40)
//                    .modifier(CustomGestureModifier(isPressed: $isPressed, f: { print("Completed") }))
//            }
//            
//            Text("Custom Gesture")
//                .font(.largeTitle)
//                .fontWeight(.heavy)
//                .foregroundColor(.blue)
//                .modifier(CustomGestureModifier(isPressed: $isPressed, f: { print("Completed") }))
//        }
//    }
//}
