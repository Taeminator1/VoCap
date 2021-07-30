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
    var notes: FetchedResults<Note>
    
    @Binding var isSettingsPresented: Bool
    
    @State var showingResetTipsSheet: Bool = false
    @State var showingEraseSheet: Bool = false
    
    @Binding var isTipsPresented: [Bool]
    
    var body: some View {
        List {
            Button(action: { showingResetTipsSheet = true }) {
                Text("Reset Tips Settings")
            }
            .actionSheet(isPresented: $showingResetTipsSheet) {
                resetTipsSettingsActionSheet
            }
            
            Button(action: { showingEraseSheet = true }) {
                Text("Erase All Data")
            }
            .actionSheet(isPresented: $showingEraseSheet) {
                eraseAllDataActionSheet
            }
        }
        .listStyle(GroupedListStyle())
//            .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Reset", displayMode: .inline)
        .accentColor(.mainColor)
    }
}

// MARK: - Action Sheet
extension ResetView {
    var resetTipsSettingsActionSheet: ActionSheet {
        ActionSheet(title: Text("This will make tips be presented again. "), 
                    buttons: [
                        .destructive(Text("Reset Tips Settings"), action: { resetTipsSettings() }),
                        .cancel(Text("Cancel"))]
        )
    }
    
    var eraseAllDataActionSheet: ActionSheet {
        ActionSheet(title: Text("This will delete all data. "),
                    buttons: [
                        .destructive(Text("Erase All Data"), action: { deleteAllData() }),
                        .cancel(Text("Cancel"))]
        )
    }
}

// MARK: - Modify notes
extension ResetView {
    func resetTipsSettings() {
        isTipsPresented[0] = false
        UserDefaults.standard.set(self.isTipsPresented[0], forKey: "Tip0")
        
        isTipsPresented[1] = false
        UserDefaults.standard.set(self.isTipsPresented[1], forKey: "Tip1")
    }
    
    func deleteAllData() {
        
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
        ResetView(isSettingsPresented: .constant(true), isTipsPresented: .constant([false, false]))
    }
}
