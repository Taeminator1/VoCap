//
//  HomeView.swift
//  VoCap
//
//  Created by 윤태민 on 12/2/20.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Text("Home View")
            Button(action: { LexicalaAPI.getJSON(userName: "Taeminator1", password: "Gksmf6890!", url: "https://dictapi.lexicala.com/entries/PW00003877")}) {
                Text("Lexicala API Test")
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
