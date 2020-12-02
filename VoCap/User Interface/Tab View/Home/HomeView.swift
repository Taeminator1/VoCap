//
//  HomeView.swift
//  VoCap
//
//  Created by 윤태민 on 12/2/20.
//

import SwiftUI

struct HomeView: View {
    @State private var word: String = ""
    
    var body: some View {
        VStack {
            NavigationLink(destination: testTextFieldView) {
                Text("Search")
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, minHeight: 35, maxHeight: 35, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 5).strokeBorder())
                    .padding(.all)
            }
        }
    }
    
    var testTextFieldView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search", text: $word, onEditingChanged: { _ in print("change") }, onCommit: { print("commit") })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: { print("Cancel") }) {
                    Text("Cancel")
                }
        }
        .padding(.all)
    }
    func testOnEditingChanged() -> Void {
        print("change")
    }
    
    func testOnCommit() -> Void {
        print("commit")
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
