//
//  AddNoteView.swift
//  VoCap
//
//  Created by 윤태민 on 12/8/20.
//

import SwiftUI

struct MakeNoteView: View {
    
    @State var note: TmpNote
    @State var dNote: TmpNote = TmpNote()           // duplicated Note
    
    @Binding var noteRowOrder: Int?
    @Binding var isPresented: Bool
    
    @State var shwoingWidgetAlert: Bool = false
    @State var shwoingAutoCheckAlert: Bool = false
    @State var showingCancelSheet: Bool = false
    
    let onComplete: (TmpNote) -> Void
    
    var body: some View {
        NavigationView {
            List {
                basicInfo
                toggleConfig
                others
            }
            .listStyle(InsetGroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)               // 이건 뭐지?
            .navigationBarTitle(noteRowOrder == nil ? "Add Note" : "Edit Note", displayMode: .inline)
            .actionSheet(isPresented: $showingCancelSheet) { actionSheet }
            .toolbar {
                // NavigationBar
                cancelButton
                doneSaveButton
            }
        }
        .onAppear() {
            dNote = note
        }
        .onDisappear() {
            noteRowOrder = nil
        }
        .allowAutoDismiss($showingCancelSheet, .constant(false)) {
            return note.isEqual(dNote)
        }
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
        noteRowOrder == nil ? Text("Are you sure you want to discard this new note?") : Text("Are you sure you want to discard your changes?")
    }
}

// MARK: - Tool Bar Items
extension MakeNoteView {
    var cancelButton: some ToolbarContent {
        CancelButton() {
            note.isEqual(dNote) ? (isPresented = false) : (showingCancelSheet = true)
        }
    }
    
    var doneSaveButton: some ToolbarContent {
        DoneButton(title: (noteRowOrder == nil ? "Save" : "Done"), isDisabled: (noteRowOrder != nil && note.isEqual(dNote))) { onComplete(note) }
    }
}

// MARK: - View of List
extension MakeNoteView {
    
    var basicInfo: some View {
        Section() {
            CustomTextField(title: "Title".localized, text: $note.title, isFirstResponder: noteRowOrder == nil)
            
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
        MakeNoteView(note: TmpNote(), noteRowOrder: .constant(nil), isPresented: .constant(false)) { _ in }
    }
}
