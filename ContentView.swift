//
//  ContentView.swift
//  VoCap
//
//  Created by 윤태민 on 1/15/21.
//

//  https://www.ioscreator.com/tutorials/swiftui-delete-multiple-rows-list-tutorial
//  https://fxstudio.dev/mini-series-swiftui-list-with-multiple-selection/
//  Modified by Taeminator

import SwiftUI

struct ContentView: View {
    @State var xxNumbers: [xxStruct] = [xxStruct(number: "1"), xxStruct(number: "2"), xxStruct(number: "3"), xxStruct(number: "4")]
    
    @State var editMode = EditMode.inactive
    @State var selection = Set<UUID>()
    
    var body: some View {
        NavigationView {
                List(selection: $selection) {
                    ForEach(xxNumbers) { number in
                        Text(number.number)
                    }
                    .onMove(perform: moveItems)
                    .onDelete(perform: deleteItems)
                }
                .animation(.default)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) { editButton }
                    
                    ToolbarItem(placement: .bottomBar) { Spacer() }
                    ToolbarItem(placement: .bottomBar) { deleteButton }
                }
                .environment(\.editMode, self.$editMode)
            }
    }
    
    private var editButton: some View {
        if editMode == .inactive {
            return Button(action: {
                self.editMode = .active
                self.selection = Set<UUID>()
            }) {
                Text("Edit")
            }
        }
        else {
            return Button(action: {
                self.editMode = .inactive
                self.selection = Set<UUID>()
            }) {
                Text("Done")
            }
        }
    }
    
    private var deleteButton: some View {
        if editMode == .inactive {
            return Button(action: {}) {
                Text("")
            }
        } else {
            return Button(action: deleteNumbers) {
                Text("Delete")
            }
        }
    }
    
    private func deleteNumbers() {
        print("\(selection.count)")
        for id in selection {
            if let index = xxNumbers.lastIndex(where: { $0.id == id })  {
                xxNumbers.remove(at: index)
            }
        }
        selection = Set<UUID>()
    }
    
    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//        }
    }
    
    private func moveItems(from source: IndexSet, to destination: Int) {
//            withAnimation {
//            }
    }
}

struct xxStruct: Identifiable {
    var id: UUID = UUID()
    var number: String = "a"
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}


