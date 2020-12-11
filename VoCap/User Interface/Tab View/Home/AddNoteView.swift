//
//  AddNoteView.swift
//  VoCap
//
//  Created by 윤태민 on 12/8/20.
//

import SwiftUI

struct AddNoteView: View {
    
    @ObservedObject var noteStore = NoteStore()
    @State var note = Note()
    
    @State private var isWidget: Bool = true
    @State private var isAutoCheck: Bool = true
    @State private var shwoingWidgetAlert: Bool = false
    @State private var shwoingAutoCheckAlert: Bool = false
    
    @Binding var showingAddNoteView: Bool
    
    var body: some View {
        NavigationView {
            List {
                basicInfo
                toggleConfig
                others
                
            }
//            .padding(.top, -90.0)           // Navigation Bar와 정확히 접점
//            .padding(.top, -73.0)           // Calender에서 Page와 일치
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)               // 이건 뭐지?
            .navigationBarItems(leading: leadingItem, trailing: trailingItem)
            .navigationBarTitle("New Note", displayMode: .inline)
            
        }
    }
}

struct AddNoteView_Previews: PreviewProvider {
    @State private var showingAddNoteView: Bool = false
    
    static var previews: some View {
        AddNoteView(showingAddNoteView: .constant(false))
    }
}


// MARK: - Navigation Bar Items
private extension AddNoteView {
    
    var leadingItem: some View {
        Button(action: cancel) {
            Text("Cancel")
        }
    }
    
    var trailingItem: some View {
        Button(action: done) {
            Text("Done")
        }
    }
    
    func cancel() {         // If there is editing, app has to ask whether discard or not
        showingAddNoteView.toggle()
    }
    
    func done() {
        let newNote = Note(id: note.id, title: note.title, colorIndex: note.colorIndex, isMemorized: note.isMemorized, isInWidget: note.isInWidget, memorizedNumber: note.memorizedNumber, totalNumber: note.totalNumber)
        
        noteStore.notes.append(newNote)
        
        showingAddNoteView.toggle()
    }
}

// MARK: - Item of AddNoteView List
private extension AddNoteView {
    
    var basicInfo: some View {
        Section() {
            TextField("Title", text: $note.title)
            
            // Group List에서 이상
            Picker(selection: $note.colorIndex, label: Text("Color")) {      // Need to check the style
                ForEach (0..<myColor.colornames.count) {
                    Text(myColor.colornames[$0])
                        .foregroundColor(myColor.colors[$0])
                }
            }
        }
    }
    
    var toggleConfig: some View {
        Section() {
            HStack {
                Text("Widget")
                Button(action: { self.shwoingWidgetAlert.toggle() }) {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(BorderlessButtonStyle())
                .alert(isPresented: $shwoingWidgetAlert) {
                    Alert(title: Text("Widget Info"))
                }
                
                
                Spacer()
                
                Toggle(isOn: self.$isWidget) {
                }
            }
            HStack {
                Text("Auto Check")
                Button(action: { self.shwoingAutoCheckAlert.toggle() }) {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(BorderlessButtonStyle())
                .alert(isPresented: $shwoingAutoCheckAlert) {
                    Alert(title: Text("Auto Check Info"))
                }
                
                Spacer()
                
                Toggle(isOn: self.$isAutoCheck) {
                }
            }
        }
    }
    
    var others: some View {
        Section() {
            VStack(alignment: .leading) {
                Text("Notes")                       // Need to add multi line textfield
                
                TextField("", text: $note.notes)
            }
        }
    }
}
