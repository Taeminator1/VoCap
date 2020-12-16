//
//  EditNoteView.swift
//  VoCap
//
//  Created by 윤태민 on 12/13/20.
//

import SwiftUI

struct EditNoteView: View {
    
    @ObservedObject var noteStore: NoteStore
    @Binding var note: Note
    
    @State private var shwoingWidgetAlert: Bool = false
    @State private var shwoingAutoCheckAlert: Bool = false
    
    @Binding var showingEditNoteView: Bool
    @Binding var isEditMode: EditMode
    
    var body: some View {
        NavigationView {
            List {
                basicInfo
                toggleConfig
                others
            }
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)               // 이건 뭐지?
            .navigationBarItems(leading: leadingItem, trailing: trailingItem)
            .navigationBarTitle("Edit Note", displayMode: .inline)
        }
    }
}

struct EditNoteView_Previews: PreviewProvider {
    static var previews: some View {
        EditNoteView(noteStore: NoteStore(), note: .constant(Note()), showingEditNoteView: .constant(true), isEditMode: .constant(.active))
    }
}


// MARK: - Navigation Bar Items
private extension EditNoteView {
    
    var leadingItem: some View {
        Button(action: cancel) {
            Text("Cancel")
        }
    }
    
    var trailingItem: some View {
        Button(action: Save) {
            Text("Save")
        }
    }
    
    // If there is editing, app has to ask whether discard or not       -> 해당 주석이 아랫줄에 있으면 Preview 오류 일으킴
    func cancel() {
        showingEditNoteView.toggle()
    }
    
    func Save() {
        
//        if let note = noteStore.notes.first(where: { $0.id == note.id }) {
//
//        }
        
        let editedNote = Note(id: note.id, title: note.title, colorIndex: note.colorIndex, isMemorized: note.isMemorized, isInWidget: note.isInWidget, memorizedNumber: note.memorizedNumber, totalNumber: note.totalNumber, notes: note.notes)
        
        if let index = noteStore.notes.firstIndex(where: { $0.id == note.id }) {
            print(index)
            noteStore.notes[index] = editedNote
        }
        
        showingEditNoteView.toggle()
        isEditMode = .inactive
    }
}

// MARK: - Item of AddNoteView List
private extension EditNoteView {
    
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
                
                Toggle(isOn: $note.isWidget) {
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
                
                Toggle(isOn: $note.isAutoCheck) {
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
