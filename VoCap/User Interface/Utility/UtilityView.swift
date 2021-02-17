//
//  LabatoryView.swift
//  VoCap
//
//  Created by 윤태민 on 12/2/20.
//

import SwiftUI

struct UtilityView: View {
//    @ObservedObject var entry = LexicalaFetchData(entryID: "PW00003877")
//    @ObservedObject var entries = LexicalaFetchData(source: "global", language: "en", text: "chair", morph: false, analyzed: true)
    
    var body: some View {
        VStack {
            Text("Utility")
                
//            Text("Home View")
//            Button(action: { test1() }) {
//                Text("get entries")
//            }
//            Button(action: { test2() }) {
//                Text("get an entry")
//            }
        }
        .toolbar {          // When access, Constraint Warning
            ToolbarItem(placement: .bottomBar) {
                Button(action: {print("1") }) {
                    Image(systemName: "1.square")
                }
            }
            
            ToolbarItem(placement: .bottomBar) { Spacer() }
            
            ToolbarItem(placement: .bottomBar) {
                Button(action: {print("2") }) {
                    Image(systemName: "2.square")
                }
            }
        }
    }
    
    func test1() -> Void {
//        for i in entries.lexicalaEntries!.results! {
//            print(i.id!)
//        }
    }
    
    func test2() -> Void {
//        for i in entry.lexicalaEntry!.senses! {
//            print(i.id!)
//            print(i.translations!["ko"]!.text!)
//        }
    }
    
    
}

struct UtilityView_Previews: PreviewProvider {
    static var previews: some View {
        UtilityView()
    }
}
