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
    @State var emailForReply: String = ""
    @State var country: String = ""
    @State var language: String = ""
    
    @State var contents: String = ""
    @State var contentsCount: Int = 0
    let textLimit: Int = 1000
    
    var body: some View {
//        NavigationView {
            List {
                optionalUserInfo
                content
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Contact Us", displayMode: .inline)
            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) { leadingItem }
                ToolbarItem(placement: .navigationBarTrailing) { trailingItem }
            }
//        }
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
        
    }
    
    func sendEmail() -> Void {
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
        builder.htmlBody  = "<p>Email for reply: \(emailForReply)<br>"
        builder.htmlBody += "Country: \(country)<br>"
        builder.htmlBody += "Language: \(language)<br>"
        builder.htmlBody += "<br><br>"
        builder.htmlBody += "Contents: \(contents)</p>"

        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperation(with: rfc822Data)
        sendOperation?.start { (error) -> Void in
            if (error != nil) {
                NSLog("Error sending email: \(String(describing: error))")
            } else {
                print(builder.htmlBody!)
                NSLog("Successfully sent email!")
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
                TextField("Korean", text: $language)
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

struct ContactUsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactUsView()
    }
}
