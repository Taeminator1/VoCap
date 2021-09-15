//
//  ListCellStyle.swift
//  VoCap
//
//  Created by 윤태민 on 9/15/21.
//

//  Modifier for cell style of list in VoCap:
//  - To hide separator on the top, the value of padding is at least -1.

import SwiftUI

enum Padding: RawRepresentable {
    case defaultRow
    case noteDetailRow

    var rawValue: (all: CGFloat, vertical: CGFloat) {
        switch self {
        case .defaultRow:       return (0.0, -1.0)
        case .noteDetailRow:    return (15.0, -5.0)
        }
    }

    init?(rawValue: (all: CGFloat, vertical: CGFloat)) {
        self = .defaultRow
    }
}

struct ListCellStyle: ViewModifier {
    var padding: Padding = .defaultRow
    
    func body(content: Content) -> some View {
        content
            .padding(padding.rawValue.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .listRowInsets(EdgeInsets())
            .background(Color(UIColor.systemBackground))
            .padding(.vertical, padding.rawValue.vertical)
    }
}

extension View {
    func listCellStyle(_ padding: Padding = .defaultRow) -> some View {
        self
            .modifier(ListCellStyle(padding: padding))
    }
}
