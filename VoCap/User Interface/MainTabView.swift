//
//  MainTabView.swift
//  VoCap
//
//  Created by 윤태민 on 12/2/20.
//

import SwiftUI

struct MainTabView: View {
    private enum Tabs {
        case home, labatory, settings
    }
    
    @State private var selectedTab: Tabs = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Group {
                home
                labatory
                settings
            }
        }
    }
}

// MARK: - MainTabView_TabItem
private extension MainTabView {
    var home: some View {
        HomeView()
            .tag(Tabs.home)
            .tabItem {
                Image(systemName: "house").imageScale(.large)
                Text("Home")
            }
    }
    
    var labatory: some View {
        LabatoryView()
            .tag(Tabs.labatory)
            .tabItem {
                Image(systemName: "plus.diamond").imageScale(.large)
                Text("Labatory")
            }
    }
    
    var settings: some View {
        SettingsView()
            .tag(Tabs.settings)
            .tabItem {
                Image(systemName: "gearshape").imageScale(.large)
                Text("Settings")
            }
    }
}

// MARK: - Previews
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .previewDevice("iPhone 11 Pro")
//        MainTabView()
//            .previewDevice("iPhone SE (2nd generation)")
//            .preferredColorScheme(.dark)
    }
}
