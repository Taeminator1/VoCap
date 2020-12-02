//
//  MainNavigationView.swift
//  VoCap
//
//  Created by 윤태민 on 12/2/20.
//

import SwiftUI

struct MainNavigationView: View {
    @State private var word: String = ""
    
    var body: some View {
        NavigationView {
            MainTabView()
                .navigationBarTitle("VoCap", displayMode: .inline)
        }
    }
}

struct MainNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        MainNavigationView()
    }
}
