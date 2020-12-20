//
//  AddNoteView.swift
//  VoCap
//
//  Created by 윤태민 on 12/8/20.
//

import SwiftUI

struct AddNoteView: View {
    
    @State var title: String = ""
    @State var colorIndex: Int = 0              // Int16으로 선언하면 Picker에서 오류 발생
    @State var isWidget: Bool = false
    @State var isAutoCheck: Bool = false
    @State var memo: String = ""
    
    @State private var shwoingWidgetAlert: Bool = false
    @State private var shwoingAutoCheckAlert: Bool = false
    
    @Binding var isAddNotePresented: Bool
    
    let onComplete: (String, Int16, String) -> Void
    
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

//struct AddNoteView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        AddNoteView(isAddNotePresented: .constant(true),
//                    onComplete: { (String, Int16, String) -> Void in
//                        return
//                    })
//    }
//}


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

    func cancel() {
        isAddNotePresented.toggle()
    }
    
    func done() {
        onComplete(title, Int16(colorIndex), memo)
    }
}

// MARK: - View of List
private extension AddNoteView {
    
    var basicInfo: some View {
        Section() {
//            TextField("Title", text: $note.title)
            CustomTextField(title: "Title", text: $title, isFirstResponder: true)
            
            // Group List에서 이상
            Picker(selection: $colorIndex, label: Text("Color")) {      // Need to check the style
                ForEach (0..<myColor.colornames.count) {
                    Text(myColor.colornames[$0])
//                        .tag(myColor.colornames[$0])                // 여기선 없어도 되는데, 용도가 있는 듯
                        .foregroundColor(myColor.colors[$0])
                }
            }
            .onAppear() {
                colorIndex = Int.random(in: 0..<myColor.colors.count)
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
                
                Toggle(isOn: $isWidget) {
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
                
                Toggle(isOn: $isAutoCheck) {
                }
            }
        }
    }
    
    var others: some View {
        Section() {
            VStack(alignment: .leading) {
                Text("Memo")                       // Need to add multi line textfield
                
                TextField("", text: $memo)
            }
        }
    }
}
