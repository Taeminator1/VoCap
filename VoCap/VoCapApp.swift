//
//  VoCapApp.swift
//  VoCap
//
//  Created by 윤태민 on 11/24/20.
//

import SwiftUI

@main
struct VoCapApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
