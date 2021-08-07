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
    
    @Binding var isPresent: Bool
    
    @State var showingResetTipsSheet: Bool = false
    @State var showingEraseSheet: Bool = false
    
    @Binding var tipControls: [TipControl]
    
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
                        .destructive(Text("Reset Tips Settings"), action: { tipControls.forEach { $0.reset() }}),
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
    func deleteAllData() {
        
        Array(0 ..< notes.count).forEach { viewContext.delete(notes[$0]) }
        saveContext()
        
        isPresent = false
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
        ResetView(isPresent: .constant(true), tipControls: .constant([TipControl(.tip0), TipControl(.tip1)]))
    }
}
