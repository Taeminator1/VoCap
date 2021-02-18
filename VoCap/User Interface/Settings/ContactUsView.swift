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
    
    @State var emailForReply: String = ""
    @State var country: String = ""
    @State var sourceLanguage: String = ""
    @State var targetLanguage: String = ""
    @State var contents: String = ""
    @State var contentsCount: Int = 0
    
    @State private var showingCancelSheet: Bool = false
    @State private var showingAlert: Bool = false
    @State var alertMessage: String = ""
    @State var sendingEmail: Bool = false
    
    let textLimit: Int = 1000
    
    var body: some View {
        NavigationView {
            List {
                optionalUserInfo
                    .disabled(sendingEmail == true)
                content
                    .disabled(sendingEmail == true)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Contact Us", displayMode: .inline)
            .actionSheet(isPresented: $showingCancelSheet) {
                ActionSheet(title: Text("Are you sure you want to discard your messages?"), message: .none,
                            buttons: [
                                .destructive(Text("Discard Messages"), action: {
                                                showingCancelSheet = false
                                                isContactUsPresented = false }),
                                .cancel(Text("Keep Editing"))]
                )
            }
            .alert(isPresented: $showingAlert) { sendEmailResultAlert }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { leadingItem }
                ToolbarItem(placement: .navigationBarTrailing) { trailingItem.disabled(contents == "" || sendingEmail == true) }
            }
            .allowAutoDismiss($showingCancelSheet) {
                return emailForReply == "" && country == "" && sourceLanguage == "" && targetLanguage == "" && contents == ""
            }
        }
    }
}

// MARK: - Tool Bar Items
private extension ContactUsView {
    var leadingItem: some View {
        Button(action: cancel) {
            Text("Cancel")
        }
    }
    
    var trailingItem: some View {
        Button(action: sendEmail) {
            Text("Send")
        }
    }
    
    func cancel() {
        if emailForReply == "" && country == "" && sourceLanguage == "" && targetLanguage == "" && contents == "" {
            isContactUsPresented = false
        }
        else {
            showingCancelSheet = true
        }
    }
    
    func sendEmail() -> Void {
        sendingEmail = true
        let smtpSession = MCOSMTPSession()
        smtpSession.hostname = "smtp.gmail.com"
        smtpSession.username = "vocap2021@gmail.com"
        smtpSession.password = "byzQat-sorvat-gyrxe9"
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
        builder.htmlBody += "Email for reply: \(emailForReply)<br>"
        builder.htmlBody += "Country: \(country)<br>"
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
                alertMessage = "Fail"
                showingAlert = true
            } else {
                print(builder.htmlBody!)
                NSLog("Successfully sent email!")
                alertMessage = "Success"
                showingAlert = true
            }
        }
    }
}

// MARK: - View of List
private extension ContactUsView {
    var optionalUserInfo: some View {
        Section(header: Text("Optional User Info")) {
            HStack {
                Text("Email for reply: ")
                TextField("vocap2021@gmail.com", text: $emailForReply)
                    .keyboardType(.emailAddress)
            }
            
            HStack {
                Text("Country: ")
                TextField("Korea", text: $country)
            }
            
            HStack {
                Text("Language: ")
                HStack {
                    TextField("source", text: $sourceLanguage)
                        .multilineTextAlignment(.center)
//                    Image(systemName: "arrow.forward")
                    Text("to")
                    TextField("target", text: $targetLanguage)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
    
    var content: some View {
        Section(
            header: Text("Contents"),
            footer: HStack {
                TextField("", value: $contentsCount, formatter: NumberFormatter())
                    .multilineTextAlignment(.trailing)
                Text("/")
                Text("\(textLimit)")
            }) {
            TextEditor(text: $contents)
                .frame(height: 200)
                .onChange(of: contents) { value in
                    contentsCount = contents.count
                }
                .onReceive(Just(contents)) { _ in limitText(textLimit)}
        }
    }
    
    func limitText(_ upper: Int) {
        if contents.count > upper {
            contents = String(contents.prefix(upper))
        }
    }
}

// MARK: - Others
private extension ContactUsView {
    var sendEmailResultAlert: Alert {
        if alertMessage == "Fail" {
            return Alert(title: Text(alertMessage),
                         message: nil,
                         primaryButton: .default(Text("Try Again"), action: { sendingEmail = false }),
                         secondaryButton: .default(Text("Cancel"), action: { isContactUsPresented = false }))
        }
        else {
            return Alert(title: Text(alertMessage), message: nil, dismissButton: .default(Text("OK"), action: { isContactUsPresented = false }))
        }
    }
}

struct ContactUsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactUsView(isContactUsPresented: .constant(true))
    }
}
