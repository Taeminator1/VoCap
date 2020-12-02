//
//  LabatoryView.swift
//  VoCap
//
//  Created by 윤태민 on 12/2/20.
//

import SwiftUI

struct LabatoryView: View {
    @ObservedObject var entry = LexicalaFetchData(entryID: "PW00003877")
    @ObservedObject var entries = LexicalaFetchData(source: "global", language: "en", text: "chair", morph: false, analyzed: true)
    
    var body: some View {
        VStack {
            Text("Home View")
            Button(action: { test1() }) {
                Text("get entries")
            }
            Button(action: { test2() }) {
                Text("get an entry")
            }
        }
    }
    
    func test1() -> Void {
        for i in entries.lexicalaEntries!.results! {
            print(i.id!)
        }
    }
    
    func test2() -> Void {
        for i in entry.lexicalaEntry!.senses! {
            print(i.id!)
            print(i.translations!["ko"]!.text!)
        }
    }
    
    
}

struct LabatoryView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
