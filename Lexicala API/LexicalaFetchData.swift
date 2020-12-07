//
//  FetchData.swift
//  VoCap
//
//  Created by 윤태민 on 12/2/20.
//

import Foundation

class LexicalaFetchData: ObservableObject {
    let login = "Taeminator1"
    let password = "Gksmf6890!"
    let urlBasicURLString = "https://dictapi.lexicala.com/"
    
    @Published var lexicalaEntries: LexicalaEntries?
    @Published var lexicalaEntry:   LexicalaEntry?
    
    init(source: String, language: String = "en", text: String, morph: Bool = false, analyzed: Bool = false) {
        var urlString = urlBasicURLString
        urlString += "search?"
        urlString += "source=\(source)&"
        urlString += "language=\(language)&"
        urlString += "text=\(text)&"
        urlString += "morph=\(morph)&"
        urlString += "analyzed=\(analyzed)"
        print(urlString)
        
        let url = URL(string: urlString)
        let config = URLSessionConfiguration.default
        let userPasswordString = "\(login):\(password)"
        let userPasswordData = userPasswordString.data(using: String.Encoding.utf8)
        let base64EncodedCredential = userPasswordData!.base64EncodedString(options: .init(rawValue: 0))
        let authString = "Basic \(base64EncodedCredential)"

        config.httpAdditionalHeaders = ["Authorization" : authString]
        let session = URLSession(configuration: config)

        session.dataTask(with: url!) { (data, response, error) in
            if error == nil && data != nil {
                let decoder = JSONDecoder()
                    do {
                        let data = try decoder.decode(LexicalaEntries.self, from: data!)
                        DispatchQueue.main.async {
                            self.lexicalaEntries = data
                            //print(data)
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
            }
        }.resume()
    }
    
    init(entryID: String) {
        var urlString = urlBasicURLString
        urlString += "entries/\(entryID)"
        print(urlString)
        
        let url = URL(string: urlString)
        let config = URLSessionConfiguration.default
        let userPasswordString = "\(login):\(password)"
        let userPasswordData = userPasswordString.data(using: String.Encoding.utf8)
        let base64EncodedCredential = userPasswordData!.base64EncodedString(options: .init(rawValue: 0))
        let authString = "Basic \(base64EncodedCredential)"
        
        config.httpAdditionalHeaders = ["Authorization" : authString]
        let session = URLSession(configuration: config)
        
        session.dataTask(with: url!) { (data, response, error) in
            if error == nil && data != nil {
                let decoder = JSONDecoder()
                    do {
                        let data = try decoder.decode(LexicalaEntry.self, from: data!)
                        DispatchQueue.main.async {
                            self.lexicalaEntry = data
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
            }
        }.resume()
    }
}

