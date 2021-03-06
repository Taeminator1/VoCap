//
//  ResetView.swift
//  VoCap
//
//  Created by 윤태민 on 3/6/21.
//

import SwiftUI

struct ResetView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.order, ascending: true)],
        animation: .default)
    private var notes: FetchedResults<Note>
    
    @Binding var isSettingsPresented: Bool
    
    @State private var showingResetTipsSheet: Bool = false
    @State private var showingEraseSheet: Bool = false
    
    @Binding var isHowToGlance: Bool
    
    var body: some View {
        List {
            Button(action: { showingResetTipsSheet = true }) {
                Text("Reset Tips Settings")
            }
            .actionSheet(isPresented: $showingResetTipsSheet) {
                ActionSheet(title: Text("This will make tips be presented again."), message: .none,
                            buttons: [
                                .destructive(Text("Reset Tips Settings"), action: { resetTipsSettings() }),
                                .cancel(Text("Cancel"))]
                )
            }
            
            Button(action: { showingEraseSheet = true }) {
                Text("Erase All Data")
            }
            .actionSheet(isPresented: $showingEraseSheet) {
                ActionSheet(title: Text("This will delete all data, returning them to defaults."), message: .none,
                            buttons: [
                                .destructive(Text("Erase All Data"), action: { deleteAllData() }),
                                .cancel(Text("Cancel"))]
                )
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Reset", displayMode: .inline)
    }
}

// MARK: - Modify notes
private extension ResetView {
    private func resetTipsSettings() {
        isHowToGlance = true
        UserDefaults.standard.set(self.isHowToGlance, forKey: "Tap")
    }
    
    private func deleteAllData() {
        
        for i in 0..<notes.count {
            viewContext.delete(notes[i])
        }
        saveContext()
        
        isSettingsPresented = false
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

struct ResetView_Previews: PreviewProvider {
    static var previews: some View {
        ResetView(isSettingsPresented: .constant(true), isHowToGlance: .constant(true))
    }
}
