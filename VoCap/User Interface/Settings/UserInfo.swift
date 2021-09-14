//
//  UserInfo.swift
//  VoCap
//
//  Created by 윤태민 on 9/14/21.
//

//  This struct is used for ContactUsView for user information

import Foundation

struct UserInfo {
    var addressForReply: String = ""
    var region: String = ""
    var sourceLanguage: String = ""
    var targetLanguage: String = ""
    var contents: String = ""
    
    var isDismissible: Bool {
        addressForReply == "" && region == "" && sourceLanguage == "" && targetLanguage == "" && contents == ""
    }
    
    var isSendable: Bool {
        contents == "" ? false : true
    }
    
    var htmlBody: String {
        "Address for reply: \(addressForReply)<br>" +
        "Region: \(region)<br>" +
        "Source Language: \(sourceLanguage)<br>" +
        "Target Language: \(targetLanguage)<br>" +
        "<br>" +
        "Contents: \(contents)"
    }
}
