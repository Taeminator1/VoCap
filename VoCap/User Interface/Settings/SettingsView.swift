//
//  SettingsView.swift
//  VoCap
//
//  Created by 윤태민 on 12/2/20.
//

import SwiftUI
import CoreData

struct SettingsView: View {

    @Binding var isSettingsPresented: Bool
    
    @State private var isContactUsPresented: Bool = false
    
    @Binding var isHowToAddItem: Bool
    @Binding var isHowToGlanceItem: Bool
    
    var body: some View {
        NavigationView {
            List {
                contactUs
                reset
            }
//            .listStyle(GroupedListStyle())
            .listStyle(InsetGroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)               // 이건 뭐지?
            .navigationBarTitle("Settings", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { leadingItem }
                ToolbarItem(placement: .navigationBarTrailing) { trailingItem }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(.mainColor)
    }
}

// MARK: - Tool Bar Items
private extension SettingsView {
    
    var leadingItem: some View {
        Button(action: { }) {
            Text("")
        }
    }
    
    var trailingItem: some View {
        Button(action: { isSettingsPresented = false }) {
            Text("Done")
        }
    }
}

// MARK: - View of List
private extension SettingsView {
    var others: some View {
        Section() {
            Text("Others")
        }
    }
    
    var contactUs: some View {
        Section() {
            Button(action: { isContactUsPresented = true }) {
                Text("Contact Us")
            }
            .sheet(isPresented: $isContactUsPresented) {
                ContactUsView(isContactUsPresented: $isContactUsPresented)
            }
        }
    }
    
    var reset: some View {
        Section() {
            NavigationLink(destination: ResetView(isSettingsPresented: $isSettingsPresented, isHowToAddItem: $isHowToAddItem, isHowToGlanceItem: $isHowToGlanceItem)) {
                Text("Reset")
            }
        }
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isSettingsPresented: .constant(true), isHowToAddItem: .constant(false), isHowToGlanceItem: .constant(false))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
