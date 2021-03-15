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
    
    @Binding var isHowToAddItem: Bool
    @Binding var isHowToGlanceItem: Bool
    
    var body: some View {
        List {
            Button(action: { showingResetTipsSheet = true }) {
                Text("Reset Tips Settings")
            }
            .actionSheet(isPresented: $showingResetTipsSheet) {
                ActionSheet(title: Text("This will make tips be presented again. "), message: .none,
                            buttons: [
                                .destructive(Text("Reset Tips Settings"), action: { resetTipsSettings() }),
                                .cancel(Text("Cancel"))]
                )
            }
            
            Button(action: { showingEraseSheet = true }) {
                Text("Erase All Data")
            }
            .actionSheet(isPresented: $showingEraseSheet) {
                ActionSheet(title: Text("This will delete all data. "), message: .none,
                            buttons: [
                                .destructive(Text("Erase All Data"), action: { deleteAllData() }),
                                .cancel(Text("Cancel"))]
                )
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Reset", displayMode: .inline)
        .accentColor(.mainColor)
    }
}

// MARK: - Modify notes
private extension ResetView {
    private func resetTipsSettings() {
        isHowToAddItem = true
        UserDefaults.standard.set(self.isHowToAddItem, forKey: "Tip0")
        
        isHowToGlanceItem = true
        UserDefaults.standard.set(self.isHowToGlanceItem, forKey: "Tip1")
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
        ResetView(isSettingsPresented: .constant(true), isHowToAddItem: .constant(true), isHowToGlanceItem: .constant(true))
    }
}
