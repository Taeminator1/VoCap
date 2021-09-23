//
//  CustomTextAlert.swift
//  VoCap
//
//  Created by 윤태민 on 2/24/21.
//

//  Struct to make new item in NoteDetailView:
//  - Inputs: term, definition.
//  - Move cursor using return key.
//  - You can Save item if at least one of the inputs is filled.
//  - If every inputs is empty, you can cancel by using return key.
//  - Cacnel by pressing cacnel button.

//  References:
//  - https://swiftuirecipes.com/blog/swiftui-alert-with-textfield
//  - https://gist.github.com/TheCodedSelf/c4f3984dd9fcc015b3ab2f9f60f8ad51

import SwiftUI

public struct TextAlert {
    var title: String                           // Title of the dialog
    var message: String                         // Dialog message
    var placeholder: String = ""                // Placeholder text for the TextField
    let next: String = "Next".localized         // The left-most button label
    let cancel: String = "Cancel".localized     // The optional cancel (right-most) button label
    var secondaryActionTitle: String? = nil     // The optional center button label
    var action: (String?, String?) -> Void      // Triggers when either of the two buttons closes the dialog
}

extension UIAlertController {

    convenience init(alert: TextAlert) {
        self.init(title: alert.title, message: alert.message, preferredStyle: .alert)
        self.view.tintColor = .mainColor

        addAction(UIAlertAction(title: alert.cancel, style: .cancel) { _ in
            alert.action(nil, nil)
        })

        var termCount = 0
        var definitionCount = 0

        var next = UIAlertAction(title: alert.next, style: .default) { _ in }
        next.isEnabled = false

        // TextField for term.
        addTextField { textField in
            textField.placeholder = "Term".localized

            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using: { _ in
                termCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0

                next.isEnabled = termCount > 0 || definitionCount > 0
            })
        }

        // TextField for definition.
        addTextField { textField in
            textField.placeholder = "Definition".localized

            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using: { _ in
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
    public func alert(isPresented: Binding<Bool>, alert: TextAlert) -> some View {
        AlertWrapper(isPresented: isPresented, alert: alert, content: self)
    }
}
