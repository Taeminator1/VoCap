//
//  AddNoteView.swift
//  VoCap
//
//  Created by 윤태민 on 12/8/20.
//

import SwiftUI

struct MakeNoteView: View {
    
    @State var note = TmpNote()
    @State var dNote = TmpNote()            // duplicated Note
    
    @Binding var isAddNotePresented: Bool
    @Binding var isEditNotePresented: Bool
    
    @State private var shwoingWidgetAlert: Bool = false
    @State private var shwoingAutoCheckAlert: Bool = false
    @State private var showingCancelSheet: Bool = false
    
    // title, colorIndex, isWidget, isAutoCheck, memo
    let onComplete: (String, Int16, Bool, Bool, String) -> Void
    
    var body: some View {
        NavigationView {
            List {
                basicInfo
//                toggleConfig
                others
            }
//            .listStyle(GroupedListStyle())
            .listStyle(InsetGroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)               // 이건 뭐지?
            .navigationBarTitle(isAddNotePresented == true ? "Add Note" : "Edit Note", displayMode: .inline)
            .actionSheet(isPresented: $showingCancelSheet) {
                ActionSheet(title: actionSheetTitle, message: .none,
                            buttons: [
                                .destructive(Text("Discard Changes"), action: {
                                                showingCancelSheet = false
                                                isAddNotePresented = false
                                                isEditNotePresented = false }),
                                .cancel(Text("Keep Editing"))]
                )
            }
            .toolbar {
                // NavigationBar
                cancelButton
                doneSaveButton
            }
        }
        .allowAutoDismiss($showingCancelSheet, .constant(false)) {
            return note.isEqual(dNote)
        }
        .accentColor(.mainColor)
    }
    
    var actionSheetTitle: Text {
        if isAddNotePresented {
            return Text("Are you sure you want to discard this new note?")
        }
        else {
            return Text("Are you sure you want to discard your changes?")
        }
    }
}


// MARK: - Tool Bar Items
private extension MakeNoteView {
    
    var cancelButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: cancel) {
                Text("Cancel")
            }
        }
    }
    
    func cancel() {
        if note.isEqual(dNote) {
            isAddNotePresented = false
            isEditNotePresented = false
        }
        else {
            showingCancelSheet = true
        }
    }
    
//    @ViewBuilder            // for conditionally view
    var doneSaveButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if isAddNotePresented == true {
                Button(action: { onComplete(note.title, Int16(note.colorIndex), note.isWidget, note.isAutoCheck, note.memo) }) {
                    Text("Done")
                }
            }
            else {
                Button(action: { onComplete(note.title, Int16(note.colorIndex), note.isWidget, note.isAutoCheck, note.memo) }) {
                    Text("Save")
                }
                .disabled(note.isEqual(dNote))
            }
        }
    }
}

// MARK: - View of List
private extension MakeNoteView {
    
    var basicInfo: some View {
        Section() {
            CustomTextField(title: "Title".localized, text: $note.title, isFirstResponder: isAddNotePresented)
            
            // Group List에서 이상
            Picker(selection: $note.colorIndex, label: Text("Color")) {      // Need to check the style
                ForEach (0..<myColor.colornames.count) {
                    Text(myColor.colornames[$0])
//                        .tag(myColor.colornames[$0])                // 여기선 없어도 되는데, 용도가 있는 듯
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
                Text("Memo")                       // Need to add multi line textfield

//                TextField("", text: $note.memo)
                TextEditor(text: $note.memo)
                    .frame(height: 150)
            }
        }
    }
}


struct MakeNoteView_Previews: PreviewProvider {
    static var previews: some View {
        MakeNoteView(isAddNotePresented: .constant(true), isEditNotePresented: .constant(false)) { _,_,_,_,_ in }
    }
}
