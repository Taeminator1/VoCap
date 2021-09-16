//
//  Visibility.swift
//  VoCap
//
//  Created by 윤태민 on 9/16/21.
//

//  Modifier about visibility for the View.
//  - It is used for EditMode of the NoteButton.

import SwiftUI

struct Visibility: ViewModifier {
    @Binding var isHidden: Bool
     
    func body(content: Content) -> some View {
       Group {
          if isHidden {
             content.hidden()
          } else {
             content
          }
       }
    }
}

extension View {
    func visibility(_ isHidden: Binding<Bool>) -> some View {
        self
            .modifier(Visibility(isHidden: isHidden))
    }
}
