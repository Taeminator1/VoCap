//
//  NoteDetailItem.swift
//  VoCap
//
//  Created by 윤태민 on 1/17/21.
//

import SwiftUI

struct NoteDetailItem: View {
    @State var tmpNoteDetail: NoteDetail
    
    var isScreen: Bool = false
    @State var isGlancing: Bool = false
    
    @State var ex: String = "abc"
    
    var editMode: EditMode = .inactive
    
    var body: some View {
        VStack {
            HStack {
                noteDetailText(tmpNoteDetail.term, strokeColor: .blue)
                    .padding(.trailing, 5.0)
                noteDetailTextField("Definition", text: $tmpNoteDetail.definition, strokeColor: .green)
                    .padding(.leading, 5.0)
            }
            .disabled(editMode == .inactive)
        }
    }
}

extension NoteDetailItem {
    
    func noteDetailTextField(_ placeholder: String = "Placeholder", text: Binding<String>, strokeColor: Color) -> some View {
        ZStack(alignment: .leading) {
//            CustomTextField(placeholder: placeholder, text: text, isFirstResponder: true)
            TextField(placeholder, text: text)
                .lineLimit(2)
//                .padding(.horizontal)
                .padding()
                .modifier(NoteDetailListModifier(strokeColor: strokeColor))
            
            Rectangle()
                .foregroundColor(strokeColor)
                .frame(width: 5)
                .frame(maxHeight: 50)
                .animation(.default)
                .onTapGesture{}                 // Scroll 되게 하려면 필요(해당 자리에)
                .modifier(CustomGestureModifier(isPressed: $isGlancing, f: { }))
        }
    }
    
    func noteDetailText(_ text: String, strokeColor: Color) -> some View {
        ZStack(alignment: .leading) {
            Text(text)
                .lineLimit(2)
                .padding(.horizontal)
                .modifier(NoteDetailListModifier(strokeColor: strokeColor))
            
            Rectangle()
                .foregroundColor(strokeColor)
                .frame(width: 5)
                .frame(maxHeight: 50)
                .animation(.default)
                .onTapGesture{}                 // Scroll 되게 하려면 필요(해당 자리에)
                .modifier(CustomGestureModifier(isPressed: $isGlancing, f: { }))
        }
    }
}

struct NoteDetailItem_Previews: PreviewProvider {
    static var previews: some View {
        NoteDetailItem(tmpNoteDetail: NoteDetail(order: 0, term: "apple", definition: "사과, 사과나무, 사과 비슷한 과일", isMemorized: true))
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light)
        
        NoteDetailItem(tmpNoteDetail: NoteDetail(order: 0, term: "book", definition: "책, 서적, 도서, 단행본, 저서, 저술, 저작, 장부, 치부책", isMemorized: false))
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}
