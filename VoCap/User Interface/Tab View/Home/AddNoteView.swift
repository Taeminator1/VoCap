//
//  AddNoteView.swift
//  VoCap
//
//  Created by 윤태민 on 12/8/20.
//

import SwiftUI

struct AddNoteView: View {
    
    var body: some View {
        NavigationView {
            List {
                Section() {             // Basic Info.
                    BasicInfoView()
                }
                
                Section() {             // Toggle Config.
                    ToggleConfigView()
                }
                
                Section() {             // Notes
                    NotesView()
                }
            }
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
            .navigationBarItems(leading: Text("Cancle"), trailing: Text("Done"))
            .navigationBarTitle("New Note", displayMode: .inline)
        }
    }
}

struct AddNoteView_Previews: PreviewProvider {
    static var previews: some View {
        AddNoteView()
    }
}

struct BasicInfoView: View {
    @State private var title: String = ""
    
    var colors: [Color] = [.black, .red, .green, .blue]
    var colornames = ["Black", "Red", "Green", "Blue"]
    
    @State private var colorIndex = 0
    
    var body: some View {
        TextField("Title", text: $title)
        
        Picker(selection: $colorIndex, label: Text("Color")) {              // Need to check the style
            ForEach (0..<colornames.count) {
                Text(self.colornames[$0])
                    .foregroundColor(self.colors[$0])
            }
        }
    }
}

struct ToggleConfigView: View {
    @State private var isWidget: Bool = true
    @State private var isAutoCheck: Bool = true
    
    var body: some View {
        HStack {
            Text("Widget")
            Button(action: { print("Widget Info.") }) {
                Image(systemName: "info.circle")
            }
            .buttonStyle(BorderlessButtonStyle())
            
            Spacer()
            
            Toggle(isOn: self.$isWidget) {
            }
        }
        HStack {
            Text("Auto Check")
            Button(action: { print("Auto Check Info.") }) {
                Image(systemName: "info.circle")
            }
            .buttonStyle(BorderlessButtonStyle())
            
            Spacer()
            
            Toggle(isOn: self.$isAutoCheck) {
            }
        }
    }
}

struct NotesView: View {
    @State private var notes: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Notes")                       // Need to add multi line textfield
            
            TextField("", text: $notes)
        }
    }
}
