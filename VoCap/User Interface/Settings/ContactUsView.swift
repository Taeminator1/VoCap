//
//  ContactUsView.swift
//  VoCap
//
//  Created by 윤태민 on 2/17/21.
//

//  View for contacting us:
//  - Input user info

//  Reference:
//  - Limit text length: https://stackoverflow.com/questions/56476007/swiftui-textfield-max-length

import SwiftUI
import Combine

struct ContactUsView: View {
    @Binding var isContactUsPresented: Bool
    @State var userInfo = UserInfo()
    
    @State var showingCancelSheet: Bool = false
    @State var showingAlert: Bool = false
    @State var alertMessage: String = ""
    @State var isSendingEmail: Bool = false
    
    let textLimit: Int = 200
    let defaultContentFrameHeight: CGFloat = 150.0
    let landscapeContentFrameHeight: CGFloat = 120.0
    
    @State var contentFrameHeight: CGFloat = 0
    @State var orientation = UIDevice.current.orientation
    let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .makeConnectable()
            .autoconnect()
    
    var body: some View {
        NavigationView {
            List {
                userInfoBlock
                    .disabled(isSendingEmail == true)
                contentBlock
                    .disabled(isSendingEmail == true)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Contact Us", displayMode: .inline)
            .actionSheet(isPresented: $showingCancelSheet) {
                actionSheet
            }
            .alert(isPresented: $showingAlert) { sendEmailResultAlert }
            .toolbar {
                cancelButton
                sendButton
            }
            .allowAutoDismiss($showingCancelSheet, $isSendingEmail) { userInfo.isDismissible }
        }
        .accentColor(.mainColor)
        .onAppear() {
            contentFrameHeight = orientation.isLandscape ? landscapeContentFrameHeight : defaultContentFrameHeight
        }
    }
}

// MARK: - Action Sheet
extension ContactUsView {
    var actionSheet: ActionSheet {
        ActionSheet(title: Text("Would you like to delete this message?"),
                    buttons: [
                        .destructive(Text("Delete"), action: {
                                        showingCancelSheet = false
                                        isContactUsPresented = false }),
                        .cancel(Text("Keep Editing"))]
        )
    }
}

// MARK: - Tool Bar Items
extension ContactUsView {
    var cancelButton: some ToolbarContent {
        CancelButton(placement: .navigationBarLeading) {
            if userInfo.isDismissible {
                isContactUsPresented = false
            }
            else {
                showingCancelSheet = true
            }
        }
    }
    
    var sendButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: sendEmail) { Text("Send") }
                .disabled(!userInfo.isSendable || isSendingEmail)
        }
    }
    
    func sendEmail() -> Void {
        isSendingEmail = true
        let smtpSession = MCOSMTPSession()
        smtpSession.hostname = "smtp.gmail.com"
        smtpSession.username = PersonalInfo.mailAddress
        smtpSession.password = PersonalInfo.mailPassword
        smtpSession.port = 465
        smtpSession.authType = MCOAuthType.saslPlain
        smtpSession.connectionType = MCOConnectionType.TLS
        smtpSession.connectionLogger = {(connectionID, type, data) in
            if data != nil {
                if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                    NSLog("Connectionlogger: \(string)")
                }
            }
        }

        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: "", mailbox: PersonalInfo.mailAddress)!]
        builder.header.from = MCOAddress(displayName: "", mailbox: PersonalInfo.mailAddress)
        builder.header.subject = ""
        builder.htmlBody  = "<p>"
        builder.htmlBody += "Version Number: \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] ?? "")<br>"
        builder.htmlBody += "Build Number: \(Bundle.main.infoDictionary!["CFBundleVersion"] ?? "")<br>"
        builder.htmlBody += "<br>"
        builder.htmlBody += userInfo.htmlBody
        builder.htmlBody += "</p>"

        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperation(with: rfc822Data)
        sendOperation?.start { (error) -> Void in
            if (error != nil) {
                NSLog("Error sending email: \(String(describing: error))")
                alertMessage = "Error"
            } else {
                NSLog("Successfully sent email!")
                alertMessage = "Success"
            }
            showingAlert = true
        }
    }
}

// MARK: - View of List
extension ContactUsView {
    var userInfoBlock: some View {
        Section(
            header: Text("User Info(Optional)")
                .padding(.top)) {
                HStack {
                    Text("Address for reply")
                        .font(.caption)
                    TextField("vocap@example.com", text: $userInfo.addressForReply)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .multilineTextAlignment(.center)
            }
            
            HStack {
                Text("Region")
                    .font(.caption)
                TextField("Country", text: $userInfo.region)
                    .multilineTextAlignment(.center)
            }
            
            HStack {
                Text("Language")
                    .font(.caption)
                HStack {
                    TextField("Source", text: $userInfo.sourceLanguage)
                        .multilineTextAlignment(.center)
                    Image(systemName: "arrow.forward")
                    TextField("Target", text: $userInfo.targetLanguage)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
    
    var contentBlock: some View {
        Section(
            header: Text("Content(Required)"),
            footer: HStack {
                Spacer()
                Text("\(textLimit - userInfo.contents.count)")
            }) {
            TextEditor(text: $userInfo.contents)
                .frame(height: contentFrameHeight)
                .onReceive(Just(userInfo.contents)) { _ in
                    if userInfo.contents.count > textLimit {
                        userInfo.contents = String(userInfo.contents.prefix(textLimit))
                    }
                }
        }
        .onReceive(orientationChanged) { _ in
            // content의 Frame 높이가 사라지는 것 방지.
            self.orientation = UIDevice.current.orientation
            contentFrameHeight = orientation.isLandscape ? landscapeContentFrameHeight : defaultContentFrameHeight
        }
    }
}

// MARK: - Alert
extension ContactUsView {
    var sendEmailResultAlert: Alert {
        if alertMessage == "Success" {
            return Alert(title: Text(alertMessage.localized),
                         message: Text("Thank you for contacting us. We will review your submission soon. "),
                         dismissButton: .default(Text("Done"), action: { isContactUsPresented = false }))
        }
        else {
            return Alert(title: Text(alertMessage.localized),
                         message: Text("Something went wrong. Please check your network status and try again. "),
                         primaryButton: .default(Text("Cancel"), action: { isContactUsPresented = false }),
                         secondaryButton: .default(Text("Back"), action: { isSendingEmail = false }))
        }
    }
}

struct ContactUsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactUsView(isContactUsPresented: .constant(true))
    }
}
