//
//  SettingsView.swift
//  VoCap
//
//  Created by 윤태민 on 12/2/20.
//

import SwiftUI
import CoreData

struct SettingsView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.order, ascending: true)],
        animation: .default)
    private var notes: FetchedResults<Note>
    
    @Binding var isSettingsPresented: Bool
    
    @State private var showingEraseSheet: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                others
                initialization
            }
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)               // 이건 뭐지?
            .navigationBarTitle("Settings", displayMode: .inline)
            .actionSheet(isPresented: $showingEraseSheet) {
                ActionSheet(title: Text("This will delete all data, returning them to defaults."), message: .none,
                            buttons: [
                                .destructive(Text("Erase All Data"), action: { deleteAllData() }),
                                .cancel(Text("Cancel"))]
                )
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { leadingItem }
                ToolbarItem(placement: .navigationBarTrailing) { trailingItem }
            }
        }
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
            NavigationLink(destination: Text("NavigationLink of tips")) {
                Text("Tips")
            }
            
            NavigationLink(destination: ContactUsView()) {
                Text("Contact with VoCap")
            }
        }
    }
    
    var initialization: some View {
        Section() {
            Button(action: { showingEraseSheet = true }) {
                Text("Erase All Data")
            }
        }
    }
}

// MARK: - Modify notes
private extension SettingsView {
    private func deleteAllData() {
        
//        // 오류 발생
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
//        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//
//        do {
//            try viewContext.execute(batchDeleteRequest)
//        } catch {
//            // Error Handling
//        }
        
        for i in 0..<notes.count {
            viewContext.delete(notes[i])
        }
        saveContext()
    }
    
    func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isSettingsPresented: .constant(true))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
