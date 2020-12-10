//
//  MainNavigationView.swift
//  VoCap
//
//  Created by 윤태민 on 12/2/20.
//

import SwiftUI

struct MainNavigationView: View {
    var body: some View {
        NavigationView {
            MainTabView()
                .navigationBarItems(leading: leadingItem, trailing: trailingItem)
                .navigationBarTitle("VoCap", displayMode: .inline)
        }
    }
}

struct MainNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        MainNavigationView()
    }
}

private extension MainNavigationView {
    var leadingItem: some View {
        NavigationLink(destination: SearchView()) {
            Image(systemName: "magnifyingglass").imageScale(.large)
        }
    }
    
    var trailingItem: some View {
        Button(action: { print("trailingItem item is tapped") }) {
            Text("Edit")
        }
    }
}
