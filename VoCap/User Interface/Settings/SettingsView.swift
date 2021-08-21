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
    
    @State var isContactUsPresented: Bool = false
    
    @Binding var tipControls: [TipControl]
    
    var body: some View {
        NavigationView {
            List {
                contactUs
                reset
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Settings", displayMode: .inline)
            .toolbar {
                doneButton
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(.mainColor)
    }
}

// MARK: - Tool Bar Items
private extension SettingsView {
    var doneButton: some ToolbarContent {
        DoneButton(placement: .navigationBarTrailing) { isSettingsPresented = false }
    }
}

// MARK: - View of List
private extension SettingsView {
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
            NavigationLink(destination: ResetView(isPresent: $isSettingsPresented, tipControls: $tipControls)) {
                Text("Reset")
            }
        }
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isSettingsPresented: .constant(true), tipControls: .constant([TipControl(.tip0), TipControl(.tip1)]))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
