//
//  Created by https://quickplan.app on 2020/11/8.
//

import SwiftUI

/// Control if allow to dismiss the sheet by the user actions
/// - Drag down on the sheet on iPhone and iPad
/// - Tap outside the sheet on iPad
/// No impact to dismiss programatically (by calling "presentationMode.wrappedValue.dismiss()")
/// -----------------
/// Tested on iOS 14.2 with Xcode 12.2 RC
/// This solution may NOT work in the furture.
/// -----------------

//  https://gist.github.com/mobilinked/9b6086b3760bcf1e5432932dad0813c0
//  edited by Taeminator1

struct MbModalHackView: UIViewControllerRepresentable {
    var dismissable: () -> Bool = { false }
    @Binding var showingCancelSheet: Bool
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MbModalHackView>) -> UIViewController {
        MbModalViewController(dismissable: self.dismissable, showingCancelSheet: $showingCancelSheet)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}

extension MbModalHackView {
    private final class MbModalViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
        let dismissable: () -> Bool
        @Binding var showingCancelSheet: Bool
        
        init(dismissable: @escaping () -> Bool, showingCancelSheet: Binding<Bool>) {
            self.dismissable = dismissable
            _showingCancelSheet = showingCancelSheet
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
            print("presentationControllerDidAttemptToDismiss")
            showingCancelSheet = true
        }
        
        // set delegate to the presentation of the root parent
        private func setup() {
            guard let rootPresentationViewController = self.rootParent.presentationController, rootPresentationViewController.delegate == nil else { return }
            rootPresentationViewController.delegate = self
        }
        
//        override func viewDidDisappear(_ animated: Bool) {
//
//        }
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

/// make the call the SwiftUI style:
/// view.allowAutDismiss(...)
extension View {
    /// Control if allow to dismiss the sheet by the user actions
//    public func allowAutoDismiss(_ dismissable: @escaping () -> Bool) -> some View {
//        self
//            .background(MbModalHackView(dismissable: dismissable))
//    }
//
//    /// Control if allow to dismiss the sheet by the user actions
//    public func allowAutoDismiss(_ dismissable: Bool) -> some View {
//        self
//            .background(MbModalHackView(dismissable: { dismissable }))
//    }
//    public func allowAutoDismiss(_ dismissable: @escaping () -> Bool, _ showingCancelSheet: Binding<Bool>) -> some View {
//        self
//            .background(MbModalHackView(dismissable: dismissable, showingCancelSheet: showingCancelSheet))
//    }
    
    public func allowAutoDismiss(_ showingCancelSheet: Binding<Bool>, _ dismissable: @escaping () -> Bool) -> some View {
        self
            .background(MbModalHackView(dismissable: dismissable, showingCancelSheet: showingCancelSheet))
    }
    
    public func allowAutoDismiss(_ dismissable: Bool, _ showingCancelSheet: Binding<Bool>) -> some View {
        self
            .background(MbModalHackView(dismissable: { dismissable }, showingCancelSheet: showingCancelSheet))
    }
}

/// Example:
// MARK: - Example
//struct ContentView: View {
//    @State private var presenting = false
//
//    var body: some View {
//        VStack {
//            Button {
//                presenting = true
//            } label: {
//                Text("Present")
//            }
//        }
//        .sheet(isPresented: $presenting) {
//            ModalContent()
//                .allowAutoDismiss { false }
//                // or
//                // .allowAutoDismiss(false)
//        }
//    }
//}

//struct ModalContent: View {
//    @Environment(\.presentationMode) private var presentationMode
//
//    var body: some View {
//        VStack {
//            Text("Hello")
//                .padding()
//
//            Button {
//                presentationMode.wrappedValue.dismiss()
//            } label: {
//                Text("Dismiss")
//            }
//        }
//    }
//}
