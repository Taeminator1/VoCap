//
//  CustomTextAlert.swift
//  VoCap
//
//  Created by 윤태민 on 2/24/21.
//

//  https://swiftuirecipes.com/blog/swiftui-alert-with-textfield
//  https://gist.github.com/TheCodedSelf/c4f3984dd9fcc015b3ab2f9f60f8ad51
//  Modified by Taeminator1

import SwiftUI

public struct TextAlert {
    public var title: String // Title of the dialog
    public var message: String // Dialog message
    public var placeholder: String = "" // Placeholder text for the TextField
    public var next: String = "Next".localized // The left-most button label
    public var cancel: String? = "Cancel".localized // The optional cancel (right-most) button label
    public var secondaryActionTitle: String? = nil // The optional center button label
    public var action: (String?, String?) -> Void // Triggers when either of the two buttons closes the dialog
    public var secondaryAction: (() -> Void)? = nil // Triggers when the optional center button is tapped
}


extension UIAlertController {
    
    convenience init(alert: TextAlert) {
        self.init(title: alert.title, message: alert.message, preferredStyle: .alert)
        self.view.tintColor = .mainColor
   
        if let cancel = alert.cancel {
            addAction(UIAlertAction(title: cancel, style: .cancel) { _ in
                alert.action(nil, nil)
            })
        }
        
        var termCount = 0
        var definitionCount = 0
        
        var next = UIAlertAction(title: alert.next, style: .default) { _ in }
        next.isEnabled = false
        
        addTextField { textField in
            textField.placeholder = "Term".localized

            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using: {_ in
                termCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                
                next.isEnabled = termCount > 0 || definitionCount > 0
            })
        }
        
        addTextField { textField in
            textField.placeholder = "Definition".localized

            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using: {_ in
                definitionCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                
                next.isEnabled = termCount > 0 || definitionCount > 0
            })
        }

        let termTextField = self.textFields?[0]
        let defTextField = self.textFields?[1]
        next = UIAlertAction(title: alert.next, style: .default) { _ in
            alert.action(termTextField?.text, defTextField?.text)
        }
        next.isEnabled = false
        addAction(next)

        if let secondaryActionTitle = alert.secondaryActionTitle {
            addAction(UIAlertAction(title: secondaryActionTitle, style: .default, handler: { _ in
                alert.secondaryAction?()
            }))
        }
        
        preferredAction = next                  // disable 이여도 action 동작하게 됨
        
    }
}

struct AlertWrapper<Content: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let alert: TextAlert
    let content: Content

    func makeUIViewController(context: UIViewControllerRepresentableContext<AlertWrapper>) -> UIHostingController<Content> {
        UIHostingController(rootView: content)
    }

    final class Coordinator {
        var alertController: UIAlertController?
        init(_ controller: UIAlertController? = nil) {
            self.alertController = controller
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: UIViewControllerRepresentableContext<AlertWrapper>) {
        
        uiViewController.rootView = content
        
        if isPresented && uiViewController.presentedViewController == nil {
            var alert = self.alert
            alert.action = {
                self.isPresented = false
                self.alert.action($0, $1)
            }
            context.coordinator.alertController = UIAlertController(alert: alert)
            uiViewController.present(context.coordinator.alertController!, animated: true)
        }
        
        if !isPresented && uiViewController.presentedViewController == context.coordinator.alertController {
            uiViewController.dismiss(animated: true)
        }
    }
}

extension View {
    public func alert(isPresented: Binding<Bool>, _ alert: TextAlert) -> some View {
        AlertWrapper(isPresented: isPresented, alert: alert, content: self)
    }
}

// MARK: - Example
//struct ContentView: View {
//    @State private var showDialog = false
//
//    var body: some View {
//        Button(action: { showDialog.toggle() }) {
//            Text("Test")
//        }
//        .alert(isPresented: $showDialog, TextAlert(title: "Title", message: "Message", action: { term, definition in
//            if let term = term, let definition = definition {
//                print("Next")
//                print(term)
//                print(definition)
//            }
//            else {
//                print("Cancel")
//            }
//        }))
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
