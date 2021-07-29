//
//  ViewExtension.swift
//  VoCap
//
//  Created by 윤태민 on 7/18/21.
//

import SwiftUI

extension View {
    func listModifier(verticalpadding: CGFloat = -1.0) -> some View {
        self
            .modifier(ListModifier(verticalPadding: verticalpadding))
    }
}

