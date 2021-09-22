//
//  CustomSheetDismiss.swift
//  VoCap
//
//  Created by https://quickplan.app on 2020/11/8.
//  Modified by Taeminator on 2021/3/26.
//

//  Control if allow to dismiss the sheet by the user actions:
//  - Drag down on the sheet.
//  - Tap outside the sheet

//  Reference: https://gist.github.com/mobilinked/9b6086b3760bcf1e5432932dad0813c0

import SwiftUI

struct MbModalHackView: UIViewControllerRepresentable {
    var dismissable: () -> Bool = { false }
    @Binding var isPresented: Bool
    @Binding var isSending: Bool
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MbModalHackView>) -> UIViewController {
        MbModalViewController(dismissable: self.dismissable, isPresented: $isPresented, isSending: $isSending)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}

extension MbModalHackView {
    private final class MbModalViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
        let dismissable: () -> Bool
        @Binding var isPresented: Bool
        @Binding var isSending: Bool
        
        init(dismissable: @escaping () -> Bool, isPresented: Binding<Bool>, isSending: Binding<Bool>) {
            self.dismissable = dismissable
            _isPresented = isPresented
            _isSending = isSending
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            
            setup()
        }
        
        func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
            return dismissable()
        }
        
        func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
            
            isPresented = !isSending
        }
        
        // set delegate to the presentation of the root parent
        private func setup() {
            guard let rootPresentationViewController = self.rootParent.presentationController, rootPresentationViewController.delegate == nil else { return }
            rootPresentationViewController.delegate = self
        }
    }
}

extension UIViewController {
    fileprivate var rootParent: UIViewController {
        if let parent = self.parent {
            return parent.rootParent
        }
        else {
            return self
        }
    }
}

extension View {
    public func allowAutoDismiss(_ isPresented: Binding<Bool>, _ isSending: Binding<Bool>, _ dismissable: @escaping () -> Bool) -> some View {
        self
            .background(MbModalHackView(dismissable: dismissable, isPresented: isPresented, isSending: isSending))
    }
}
