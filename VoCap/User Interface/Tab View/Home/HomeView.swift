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
            Text("Home View")
//            NavigationLink(destination: SearchView()) {
//                Text("Search")
//                    .foregroundColor(Color.black)
//                    .multilineTextAlignment(.leading)
//                    .frame(maxWidth: .infinity, minHeight: 35, maxHeight: 35, alignment: .leading)
//                    .background(RoundedRectangle(cornerRadius: 5).strokeBorder())
//                    .padding(.all)
//
//            }
//            Spacer()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
