//
//  TestView.swift
//  VoCap
//
//  Created by 윤태민 on 2/16/21.
//

import SwiftUI

struct TestView: View {
    @State private var term: String = "kind"
    @State private var definition: String = "??"
    
    var body: some View {
        VStack {
            HStack {
                TextField("Term", text: $term)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                Button(action: { getDefinitions() }) {
                    Text("Search")
                }
            }
            TextField("Term", text: $definition)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
    }
    
    func getDefinitions() {
        definition = ""
        let passwordEntries = LexicalaFetchData(source: "password", text: term)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            if let results = passwordEntries.lexicalaEntries!.results {
                for result in results {
                    if let id = result.id {
                        let passwordEntry = LexicalaFetchData(entryID: id)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            if let results = passwordEntry.lexicalaEntry!.senses {
                                for result in results {
                                    definition += result.translations!["ko"]!.text!
                                    definition += ", "
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
