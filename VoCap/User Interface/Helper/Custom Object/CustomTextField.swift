//
//  CustomTextField.swift
//  VoCap
//
//  Created by 윤태민 on 12/14/20.
//

//  TextFiled for responding first.
//  - It is used in MakeNoteView.

//  References:
//  - https://stackoverflow.com/questions/56507839/swiftui-how-to-make-textfield-become-first-responder
//  - https://stackoverflow.com/questions/58311022/autofocus-textfield-programmatically-in-swiftui

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
            text = textField.text ?? ""
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return false
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            textField.resignFirstResponder()
        }
    }

    var title: String = ""                  // Placeholder.
    @Binding var text: String               // Text in TextFiled.
    var isFirstResponder: Bool = false      // To make respond first or not.

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

