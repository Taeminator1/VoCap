//
//  CustomTextField.swift
//  VoCap
//
//  Created by 윤태민 on 12/14/20.
//

//  아래 URL에 나온 코드를 수정하여 작성
//  https://stackoverflow.com/questions/56507839/swiftui-how-to-make-textfield-become-first-responder
//  추후 참고: https://stackoverflow.com/questions/58311022/autofocus-textfield-programmatically-in-swiftui

import Foundation
import SwiftUI

struct CustomTextField: UIViewRepresentable {
    
    class Coordinator: NSObject, UITextFieldDelegate {

        @Binding var text: String
        var didBecomeFirstResponder = false

        init(text: Binding<String>) {
            _text = text
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
//            print("a")
            text = textField.text ?? ""
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//            print("b")
            textField.resignFirstResponder()
            return false
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            textField.resignFirstResponder()
//            print("c")
        }
    }

    var title: String = ""              // Placeholder
    @Binding var text: String
    var isFirstResponder: Bool = false

    func makeUIView(context: UIViewRepresentableContext<CustomTextField>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.placeholder = title
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.delegate = context.coordinator
        return textField
    }

    func makeCoordinator() -> CustomTextField.Coordinator {
        return Coordinator(text: $text)
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomTextField>) {
        uiView.text = text
        if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
}

