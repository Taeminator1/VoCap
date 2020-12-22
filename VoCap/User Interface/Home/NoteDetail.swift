//
//  NoteDetail.swift
//  VoCap
//
//  Created by 윤태민 on 12/9/20.
//

import SwiftUI

struct NoteDetail: View {
    var title: String?
    var body: some View {
        Text(title!)
            .toolbar {          // When access, Constraint Warning
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {print("1") }) {
                        Image(systemName: "1.square.fill")
                    }
                }
                
                ToolbarItem(placement: .bottomBar) { Spacer() }
                
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {print("2") }) {
                        Image(systemName: "2.square.fill")
                    }
                }
            }
    }
}

struct NoteDetail_Previews: PreviewProvider {
    static var previews: some View {
        NoteDetail(title: "sample")
    }
}
