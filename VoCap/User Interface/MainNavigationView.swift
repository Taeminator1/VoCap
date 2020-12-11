//
//  MainNavigationView.swift
//  VoCap
//
//  Created by 윤태민 on 12/2/20.
//

import SwiftUI

struct MainNavigationView: View {
    @State var isEditMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            MainTabView()
                .navigationBarItems(leading: leadingItem, trailing: EditButton())
                .navigationBarTitle("VoCap", displayMode: .inline)
                .environment(\.editMode, self.$isEditMode)          // 없으면 Edit 안 먹힘(해당 위치에 있어야 함)
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
}
