//
//  XxCustomTextField.swift
//  VoCap
//
//  Created by 윤태민 on 1/31/21.
//

//  숫자를 입력하면 자동으로 다음 TextField로 넘어감
//  https://www.hackingwithswift.com/forums/100-days-of-swiftui/jump-focus-between-a-series-of-textfields-pin-code-style-entry-widget/765
//  TextField간 전환 가능하도록 버튼 추가(기존에는 한 번 전환되면 다시 돌아가지 못함_주석 부분)

//  close 버튼을 누르면 keyboard가 사라짐
//  https://gist.github.com/wilsoncusack/6e80af92cf86bfae768bda7c64009789

//  Keyboard 위에 버튼 추가
//  https://stackoverflow.com/questions/59003612/extend-swiftui-keyboard-with-custom-button

import SwiftUI

struct YyCustomTextField: UIViewRepresentable {
    
    class Coordinator: NSObject, UITextFieldDelegate {

        @Binding var text: String
        @Binding var selectedRow: Int
        @Binding var selectedCol: Int
        @Binding var closeKeyboard: Bool

        init(text: Binding<String>, selectedRow: Binding<Int>, selectedCol: Binding<Int>, closeKeyboard: Binding<Bool>) {
            _text = text
            _selectedRow = selectedRow
            _selectedCol = selectedCol
            _closeKeyboard = closeKeyboard
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.text = textField.text ?? ""
            }
        }
        
//        func textFieldDidEndEditing(_ textField: UITextField) {
//            print("d")
//            selectedRow = -1
//            selectedCol = -1
//        }
    }

    var title: String = ""              // Placeholder
    @Binding var text: String
    @Binding var selectedRow: Int
    @Binding var selectedCol: Int
    @Binding var isEnabled: Bool
    @Binding var closeKeyboard: Bool
    let col: Int
    
    var isFirstResponder: Bool = false

    func makeUIView(context: UIViewRepresentableContext<YyCustomTextField>) -> UITextField {
        let textField = YyCustomUITextField(selectedRow: $selectedRow, selectedCol: $selectedCol, closeKeyboard: $closeKeyboard)
        textField.placeholder = title
        textField.delegate = context.coordinator
        textField.autocapitalizationType = .none
        textField.textAlignment = .left
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//        textField.keyboardAppearance = UIKeyboardAppearance.dark

        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        
        let moveLeftButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(textField.moveLeft))
        
        let moveRightButton = UIBarButtonItem(image: UIImage(systemName: "chevron.right"), style: .plain, target: self, action: #selector(textField.moveRight(button:)))
        
        let moveLeftRightButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left.slash.chevron.right"), style: .plain, target: self, action: #selector(textField.moveLeftRight(button:)))
        
        let space = UIBarButtonItem(title: " ")
        
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(textField.done(button:)))
        
        print("\(col)")
        
        switch col {
        case 0:
            toolBar.setItems([moveRightButton, flexible, doneButton], animated: true)
            textField.inputAccessoryView = toolBar
        case 1:
            toolBar.setItems([moveLeftButton, flexible, doneButton], animated: true)
            textField.inputAccessoryView = toolBar
        default:
            toolBar.setItems([moveLeftButton, space, moveRightButton, flexible, doneButton], animated: true)
            textField.inputAccessoryView = toolBar
        }
        
//        toolBar.setItems([moveLeftRightButton, flexible, doneButton], animated: true)
//        textField.inputAccessoryView = toolBar
        
        return textField
    }

    func makeCoordinator() -> YyCustomTextField.Coordinator {
        return Coordinator(text: $text, selectedRow: $selectedRow, selectedCol: $selectedCol, closeKeyboard: $closeKeyboard)
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<YyCustomTextField>) {
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


class YyCustomUITextField: UITextField {
    
    let numberOfRows: Int = 0
    let numberOfCols: Int = 2
    @Binding var selectedRow: Int
    @Binding var selectedCol: Int
    @Binding var closeKeyboard: Bool
    
    
    init(selectedRow: Binding<Int>, selectedCol: Binding<Int>, closeKeyboard: Binding<Bool>) {
        _selectedRow = selectedRow
        _selectedCol = selectedCol
        _closeKeyboard = closeKeyboard
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func moveLeft(button: UIBarButtonItem) -> Void {
        if selectedCol > 0 {
            self.selectedCol -= 1
        }
    }
    
    @objc func moveRight(button: UIBarButtonItem) -> Void {
        if selectedCol < numberOfCols - 1 {
            self.selectedCol += 1
        }
    }
    
    @objc func moveLeftRight(button: UIBarButtonItem) -> Void {
        if selectedCol == 0     { selectedCol = 1 }
        else                    { selectedCol = 0 }
    }
    
    @objc func moveDown(button: UIBarButtonItem) -> Void {
        if selectedRow < numberOfRows - 1 {
            self.selectedRow += 1
        }
    }
    
    @objc func moveUp(button: UIBarButtonItem) -> Void {
        if selectedRow > 0 {
            self.selectedRow -= 1
        }
    }
    
    @objc func done(button: UIBarButtonItem) -> Void {
//        self.resignFirstResponder()
        selectedRow = -1
        selectedCol = -1
        closeKeyboard = true
    }
}
