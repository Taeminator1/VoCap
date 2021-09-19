//
//  AddNoteView.swift
//  VoCap
//
//  Created by 윤태민 on 12/8/20.
//

//  To add or edit note:
//  - Add Note: Don't need to fill out the form.
//  - Edit Note: Need to change at least one thing.
//  - Tell add or edit by order variable.

//  Things to do:
//  - Add toggleConfig

import SwiftUI

struct MakeNoteView: View {
    @State var note: TmpNote
    @State private var dNote: TmpNote = TmpNote()           // Duplicated Note to compare to prior note.
    
    @Binding var order: Int?                        // Optional type to tell functions, make or edit.
    @Binding var isPresented: Bool
    
    @State private var shwoingWidgetAlert: Bool = false
    @State private var shwoingAutoCheckAlert: Bool = false
    @State private var showingCancelSheet: Bool = false
    
    let onComplete: (TmpNote) -> Void
    
    var body: some View {
        NavigationView {
            List {
                basicInfo
//                toggleConfig
                others
            }
            .listStyle(InsetGroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
            .navigationBarTitle(order == nil ? "Add Note" : "Edit Note", displayMode: .inline)
            .actionSheet(isPresented: $showingCancelSheet) { actionSheet }
            .toolbar {
                cancelButton
                doneSaveButton
            }
        }
        .onAppear() { dNote = note }
        .onDisappear() { order = nil }
        .allowAutoDismiss($showingCancelSheet, .constant(false)) { note.isEqual(dNote) }
        .accentColor(.mainColor)
    }
}

// MARK: - Action Sheet
extension MakeNoteView {
    var actionSheet: ActionSheet {
        ActionSheet(title: actionSheetTitle,
                    buttons: [
                        .destructive(Text("Discard Changes"), action: {
                                        showingCancelSheet = false
                                        isPresented = false }),
                        .cancel(Text("Keep Editing"))]
        )
    }
    
    var actionSheetTitle: Text {
        order == nil ? Text("Are you sure you want to discard this new note?") : Text("Are you sure you want to discard your changes?")
    }
}

// MARK: - Tool Bar Items
extension MakeNoteView {
    var cancelButton: some ToolbarContent {
        CancelButton(placement: .navigationBarLeading) {
            note.isEqual(dNote) ? (isPresented = false) : (showingCancelSheet = true)
        }
    }
    
    var doneSaveButton: some ToolbarContent {
        DoneButton(placement: .navigationBarTrailing, title: (order == nil ? "Save" : "Done"), isDisabled: (order != nil && note.isEqual(dNote))) { onComplete(note) }
    }
}

// MARK: - View of List
extension MakeNoteView {
    var basicInfo: some View {
        Section() {
            CustomTextField(title: "Title".localized, text: $note.title, isFirstResponder: order == nil)
            
            // Group List에서 이상
            Picker(selection: $note.colorIndex, label: Text("Color")) {      // Need to check the style
                ForEach (0 ..< Pallet.colors.count) {
                    Text(Pallet.colors[$0].name)
                        .foregroundColor(Pallet.colors[$0].value)
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
                TextEditor(text: $note.memo)
                    .frame(height: 150)
            }
        }
    }
}


struct MakeNoteView_Previews: PreviewProvider {
    static var previews: some View {
        MakeNoteView(note: TmpNote(), order: .constant(nil), isPresented: .constant(false)) { _ in }
    }
}
