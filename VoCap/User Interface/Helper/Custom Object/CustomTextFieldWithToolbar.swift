//
//  CustomTextFieldWithToolbar.swift
//  VoCap
//
//  Created by 윤태민 on 1/31/21.
//

//  TextFiled for NoteDetailView:
//  - Go to another cell:
//      - Using keyboard toolbar button.
//      - With keyboard using isFirsResponder variable.
//  - Close the keyboard from the keyboard.

//  Reference:
//  - https://www.hackingwithswift.com/forums/100-days-of-swiftui/jump-focus-between-a-series-of-textfields-pin-code-style-entry-widget/765
//  - https://gist.github.com/wilsoncusack/6e80af92cf86bfae768bda7c64009789
//  - https://stackoverflow.com/questions/59003612/extend-swiftui-keyboard-with-custom-button

import SwiftUI

struct CustomTextFieldWithToolbar: UIViewRepresentable {

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        @Binding var location: CellLocation
        @Binding var closeKeyboard: Bool

        init(text: Binding<String>, location: Binding<CellLocation>, closeKeyboard: Binding<Bool>) {
            _text = text
            _location = location
            _closeKeyboard = closeKeyboard
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.text = textField.text ?? ""
            }
        }
    }

    var title: String = ""                  // Placeholder
    @Binding var text: String
    @Binding var location: CellLocation     // Location of table.
    @Binding var closeKeyboard: Bool
    
    var isFirstResponder: Bool = false

    func makeUIView(context: UIViewRepresentableContext<CustomTextFieldWithToolbar>) -> UITextField {
        let textField = CustomUITextField(location: $location, closeKeyboard: $closeKeyboard)
        textField.placeholder = title
        textField.delegate = context.coordinator
        textField.autocapitalizationType = .none
        textField.textAlignment = .left
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        
        let moveLeftButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(textField.moveLeft))
        let moveRightButton = UIBarButtonItem(image: UIImage(systemName: "chevron.right"), style: .plain, target: self, action: #selector(textField.moveRight))
        let space = UIBarButtonItem(title: " ")
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(textField.done))
        
        switch location.col {
        case 0:
            toolbar.setItems([moveRightButton, flexible, doneButton], animated: true)
        case 1:
            toolbar.setItems([moveLeftButton, flexible, doneButton], animated: true)
        default:
            toolbar.setItems([moveLeftButton, space, moveRightButton, flexible, doneButton], animated: true)
        }
        textField.inputAccessoryView = toolbar
        
        return textField
    }

    func makeCoordinator() -> CustomTextFieldWithToolbar.Coordinator {
        return Coordinator(text: $text, location: $location, closeKeyboard: $closeKeyboard)
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomTextFieldWithToolbar>) {
        uiView.text = text
        if isFirstResponder {
            uiView.becomeFirstResponder()
        }
        
        if closeKeyboard {
            uiView.resignFirstResponder()
            closeKeyboard = false
        }
    }
}


class CustomUITextField: UITextField {
    
    let numberOfRows: Int = 0
    let numberOfCols: Int = 2
    @Binding var location: CellLocation
    @Binding var closeKeyboard: Bool
    
    init(location: Binding<CellLocation>, closeKeyboard: Binding<Bool>) {
        _location = location
        _closeKeyboard = closeKeyboard
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func moveLeft(button: UIBarButtonItem) -> Void {
        if location.col > 0 {
            self.location.col -= 1
        }
    }
    
    @objc func moveRight(button: UIBarButtonItem) -> Void {
        if location.col < numberOfCols - 1 {
            self.location.col += 1
        }
    }
    
    @objc func moveDown(button: UIBarButtonItem) -> Void {
        if location.row < numberOfRows - 1 {
            self.location.row += 1
        }
    }
    
    @objc func moveUp(button: UIBarButtonItem) -> Void {
        if location.row > 0 {
            self.location.row -= 1
        }
    }
    
    @objc func done(button: UIBarButtonItem) -> Void {
        location = CellLocation()
        closeKeyboard = true
    }
}
