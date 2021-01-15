//
//  ContentView.swift
//  VoCap
//
//  Created by 윤태민 on 1/15/21.
//

//  https://www.ioscreator.com/tutorials/swiftui-delete-multiple-rows-list-tutorial
//  Modified by Taeminator

import SwiftUI

struct ContentView: View {
    @State var numbers = ["One","Two","Three","Four","Five","Six","Seven","Eight","Nine","Ten"]
    @State var editMode = EditMode.inactive
    @State var selection = Set<String>()
    
    var body: some View {
        NavigationView {
                List(selection: $selection) {
                    ForEach(numbers, id: \.self) { number in
                        Text(number)
                    }
                    .onMove(perform: moveItems)
                    .onDelete(perform: deleteItems)
                }
                .animation(.default)
                 // 2.
                .navigationBarItems(leading: deleteButton, trailing: editButton)
                 // 3.
                .environment(\.editMode, self.$editMode)
            }
    }
    
    private var editButton: some View {
        if editMode == .inactive {
            return Button(action: {
                self.editMode = .active
                self.selection = Set<String>()
            }) {
                Text("Edit")
            }
        }
        else {
            return Button(action: {
                self.editMode = .inactive
                self.selection = Set<String>()
            }) {
                Text("Done")
            }
        }
    }
    
    private var deleteButton: some View {
        if editMode == .inactive {
            return Button(action: {}) {
                Image(systemName: "square")
            }
        } else {
            return Button(action: deleteNumbers) {
                Image(systemName: "trash")
            }
        }
    }
    
    private func deleteNumbers() {
        for id in selection {
            if let index = numbers.lastIndex(where: { $0 == id })  {
                numbers.remove(at: index)
            }
        }
        selection = Set<String>()
    }
    
    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//        }
    }
    
    private func moveItems(from source: IndexSet, to destination: Int) {
//            withAnimation {
//
//            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


