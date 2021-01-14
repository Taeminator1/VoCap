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

struct CustomGestureModifierExample: View {
    @State var isPressed = false
    @Namespace var namespace
    
    @State private var counter: Int = 0
    @State private var timer: Timer?
    @State var isLongPressing = false
    
    @State var isLongPressing2 = false
    
    var body: some View {
        VStack(alignment: .trailing) {
            
            if isPressed {
                Rectangle()
                    .foregroundColor(.blue)
                    .matchedGeometryEffect(id: "abc", in: namespace)
                    .animation(.default)
                    .frame(maxWidth: 10, maxHeight: 40)
                    .modifier(CustomGestureModifier(isPressed: $isPressed, f: { print("Completed") }))
            }
            else {
                Rectangle()
                    .foregroundColor(.blue)
                    .matchedGeometryEffect(id: "abc", in: namespace)
                    .animation(.default)
                    .frame(maxWidth: 100, maxHeight: 40)
                    .modifier(CustomGestureModifier(isPressed: $isPressed, f: { print("Completed") }))
            }
            
            Text("Custom Gesture")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(.blue)
                .modifier(CustomGestureModifier(isPressed: $isPressed, f: { print("Completed") }))
            
// MARK: -
            

            CustomButton(isLongPressing: $isLongPressing2, minimumDuration: 0.1)
                .foregroundColor(.blue)
                .frame(width: 5, height: 80)
                .scaleEffect(x: isLongPressing2 ? 35 : 1, y: 1, anchor: .trailing)
                .animation(.default)
        }
    }
}

struct NoEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
    }
}


// https://adampaxton.com/make-a-press-and-hold-fast-forward-button-in-swiftui/

struct CustomButton: View {
    @Binding var isLongPressing: Bool
    var minimumDuration: Double = 0.2
    
    var body: some View {
        Button(action: {
//            print("Pressed")
            isLongPressing = false
        }) {
            Rectangle()
        }
        .buttonStyle(NoEffectButtonStyle())
        .gesture(DragGesture()
                                .onEnded { _ in
//                                    print("Dragged")
                                    if self.isLongPressing {
                                        self.isLongPressing = false
                                    }
                                }
        )
        .simultaneousGesture(LongPressGesture(minimumDuration: minimumDuration)
                    .onEnded { _ in
//                        print("Long Pressing")
                        self.isLongPressing = true
                    }
        )
    }
}
