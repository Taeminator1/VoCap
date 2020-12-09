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
    static var previews: some View {
        AddNoteView()
    }
}

private extension AddNoteView {
    var leadingItem: some View {
        Button(action: { print("leadingItem item is tapped") }) {
            Text("Cancel")
        }
    }
    
    var trailingItem: some View {
        Button(action: { print("trailingItem item is tapped") }) {
            Text("Done")
        }
    }
}

struct BasicInfoView: View {
    @State private var title: String = ""
    
    var colors: [Color] = [.black, .red, .green, .blue]
    var colornames = ["Black", "Red", "Green", "Blue"]
    
    @State private var colorIndex = 0
    
    var body: some View {
        TextField("Title", text: $title)
        
        // Group List에서 이상
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
    @State private var shwoingWidgetAlert: Bool = false
    @State private var shwoingAutoCheckAlert: Bool = false
    
    var body: some View {
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

struct NotesView: View {
    @State private var notes: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Notes")                       // Need to add multi line textfield
            
            TextField("", text: $notes)
        }
    }
}
