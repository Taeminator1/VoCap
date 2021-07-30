//
//  ContactUsView.swift
//  VoCap
//
//  Created by 윤태민 on 2/17/21.
//

//  make TextEditor limit length
//  https://stackoverflow.com/questions/56476007/swiftui-textfield-max-length
import SwiftUI
import Combine

struct ContactUsView: View {
    @Binding var isContactUsPresented: Bool
    
    @State var addressForReply: String = ""
    @State var region: String = ""
    @State var sourceLanguage: String = ""
    @State var targetLanguage: String = ""
    @State var contents: String = ""
    @State var contentsCount: Int = 0
    
    @State var showingCancelSheet: Bool = false
    @State var showingAlert: Bool = false
    @State var alertMessage: String = ""
    @State var isSendingEmail: Bool = false
    
    let textLimit: Int = 200
    
    @State var contentFrameHeight: CGFloat = 150
    @State var orientation = UIDevice.current.orientation
    let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .makeConnectable()
            .autoconnect()
    
    var body: some View {
        NavigationView {
            List {
                userInfo
                    .disabled(isSendingEmail == true)
                content
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
            .allowAutoDismiss($showingCancelSheet, $isSendingEmail) {
                return addressForReply == "" && region == "" && sourceLanguage == "" && targetLanguage == "" && contents == ""
            }
        }
        .accentColor(.mainColor)
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
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: cancel) { Text("Cancel") }
        }
    }
    
    var sendButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: sendEmail) { Text("Send") }
                .disabled(contents == "" || isSendingEmail)
        }
    }
    
    func cancel() {
        if addressForReply == "" && region == "" && sourceLanguage == "" && targetLanguage == "" && contents == "" {
            isContactUsPresented = false
        }
        else {
            showingCancelSheet = true
        }
    }
    
    func sendEmail() -> Void {
        isSendingEmail = true
        let smtpSession = MCOSMTPSession()
        smtpSession.hostname = "smtp.gmail.com"
        smtpSession.username = "vocap2021@gmail.com"
        smtpSession.password = "cyzsar-xywsy9-zumZuc"
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
        builder.header.to = [MCOAddress(displayName: "", mailbox: "vocap2021@gmail.com")!]
        builder.header.from = MCOAddress(displayName: "", mailbox: "vocap2021@gmail.com")
        builder.header.subject = ""
        builder.htmlBody  = "<p>"
        builder.htmlBody += "Version Number: \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] ?? "")<br>"
        builder.htmlBody += "Build Number: \(Bundle.main.infoDictionary!["CFBundleVersion"] ?? "")<br>"
        builder.htmlBody += "<br>"
        builder.htmlBody += "Address for reply: \(addressForReply)<br>"
        builder.htmlBody += "Region: \(region)<br>"
        builder.htmlBody += "Source Language: \(sourceLanguage)<br>"
        builder.htmlBody += "Target Language: \(targetLanguage)<br>"
        builder.htmlBody += "<br>"
        builder.htmlBody += "Contents: \(contents)"
        builder.htmlBody += "</p>"

        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperation(with: rfc822Data)
        sendOperation?.start { (error) -> Void in
            if (error != nil) {
                NSLog("Error sending email: \(String(describing: error))")
                alertMessage = "Error"
                showingAlert = true
            } else {
//                print(builder.htmlBody!)
                NSLog("Successfully sent email!")
                alertMessage = "Success"
                showingAlert = true
            }
        }
    }
}

// MARK: - View of List
extension ContactUsView {
    var userInfo: some View {
        Section(
            header: Text("User Info(Optional)")
                .padding(.top)) {
                HStack {
                    Text("Address for reply")
                        .font(.caption)
                    TextField("vocap@example.com", text: $addressForReply)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .multilineTextAlignment(.center)
            }
            
            HStack {
                Text("Region")
                    .font(.caption)
                TextField("Country", text: $region)
                    .multilineTextAlignment(.center)
            }
            
            HStack {
                Text("Language")
                    .font(.caption)
                HStack {
                    TextField("Source", text: $sourceLanguage)
                        .multilineTextAlignment(.center)
                    Image(systemName: "arrow.forward")
//                    Text("to")
                    TextField("Target", text: $targetLanguage)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
    
    var content: some View {
        Section(
            header: Text("Content(Required)"),
            footer: HStack {
                Spacer()
                Text("\(textLimit - contentsCount)")
            }) {
            TextEditor(text: $contents)
                .frame(height: contentFrameHeight)
                .onChange(of: contents) { value in
                    contentsCount = contents.count
                }
                .onReceive(Just(contents)) { _ in limitText(textLimit)}
        }
        .onReceive(orientationChanged) { _ in                   // content의 Frame size Height가 변경되는 것 방지
            self.orientation = UIDevice.current.orientation
//            print(orientation.isLandscape)
            if orientation.isLandscape {
                contentFrameHeight = 150.1
            }
            else {
                contentFrameHeight = 150.0
            }
//            print(contentFrameHeight)
        }
    }
    
    func limitText(_ upper: Int) {
        if contents.count > upper {
            contents = String(contents.prefix(upper))
        }
    }
}

// MARK: - Others
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
