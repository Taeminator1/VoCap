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
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)               // 이건 뭐지?
            .navigationBarItems(leading: leadingItem, trailing: trailingItem)
            .navigationBarTitle("New Note", displayMode: .inline)
            
        }
    }
}

struct AddNoteView_Previews: PreviewProvider {
    static var previews: some View {
        AddNoteView(noteStore: NoteStore(), showingAddNoteView: .constant(true))
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
    
    // If there is editing, app has to ask whether discard or not       -> 해당 주석이 아랫줄에 있으면 Preview 오류 일으킴
    func cancel() {
        showingAddNoteView.toggle()
    }
    
    func done() {
        let newNote = Note(id: note.id, title: note.title, colorIndex: note.colorIndex, isMemorized: note.isMemorized, isInWidget: note.isInWidget, memorizedNumber: note.memorizedNumber, totalNumber: note.totalNumber, notes: note.notes)
        
        noteStore.notes.append(newNote)
        
        showingAddNoteView.toggle()
    }
}

// MARK: - Item of AddNoteView List
private extension AddNoteView {
    
    var basicInfo: some View {
        Section() {
//            TextField("Title", text: $note.title)
            CustomTextField(title: "Title", text: $note.title, isFirstResponder: true)
            
            // Group List에서 이상
            Picker(selection: $note.colorIndex, label: Text("Color")) {      // Need to check the style
                ForEach (0..<myColor.colornames.count) {
                    Text(myColor.colornames[$0])
                        .foregroundColor(myColor.colors[$0])
                }
            }
            .onAppear() {
                note.colorIndex = Int.random(in: 0..<myColor.colors.count)
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
