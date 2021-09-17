//
//  GiFViewStyle.swift
//  VoCap
//
//  Created by 윤태민 on 9/17/21.
//

//  Modifier for GifView.

import SwiftUI

struct GiFViewStyle: ViewModifier {
    let order: Int
    
    func body(content: Content) -> some View {
        content
            .frame(width: TipInfo.tips[order].viewSize.width, height: TipInfo.tips[order].viewSize.height)
            .cornerRadius(12)
    }
}

extension View {
    func gifViewStyle(_ order: Int) -> some View {
        self
            .modifier(GiFViewStyle(order: order))
    }
}
