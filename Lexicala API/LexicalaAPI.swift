//
//  LexicalaAPI.swift
//  VoCap
//
//  Created by 윤태민 on 12/2/20.
//

import Foundation

struct LexicalaAPI {
    static var testString: String = ""                  // 데이터 저장 전에 호출될 수 있음 -> DispatchQueue 고려
    
    static func getJSON(userName: String, password: String, url: String) -> Void {
        let url = URL(string: url)
//        let request = URLRequest(url: url!)
        let config = URLSessionConfiguration.default
        let userNamePasswordString = "\(userName):\(password)"
        let userNamePasswordData = userNamePasswordString.data(using: String.Encoding.utf8)
        let base64EncodedCredential = userNamePasswordData!.base64EncodedString(options: .init(rawValue: 0))
        let authString = "Basic \(base64EncodedCredential)"
        
        config.httpAdditionalHeaders = ["Authorization" : authString]
        
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: url!) { (data, response, error) in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            self.testString = String(data: data!, encoding: .utf8)!
            print(self.testString)
        }
        task.resume()
    }
}
