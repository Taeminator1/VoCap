//
//  TipView.swift
//  VoCap
//
//  Created by 윤태민 on 7/30/21.
//

import SwiftUI

struct TipView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let tiptype: TipType
    @Binding var tipControls: [TipControl]
    
    var body: some View {
        Group {
            if tipControls[tiptype.rawValue].isPresented {
                Rectangle()
                    .fill(Color.black.opacity(0.4))
                    .ignoresSafeArea()
                    .overlay(
                        Button(action: { tipControls[tiptype.rawValue].makeTipDisabled() }) { tip }
                        .buttonStyle(PlainButtonStyle())
                    )
            }
            else {
                EmptyView()
            }
        }
    }
}

extension TipView {
    private var tip: some View {
        ZStack {
//            GifView(fileName: "\(TipInfo.fileNames[info.order])_\(colorScheme)")      Tip 띄어진 상태에서 Dark/Light 변경하면 반영 안 됨
            
            if colorScheme == .light { GifView(fileName: "\(TipInfo.tips[tiptype.rawValue].fileName)_\(colorScheme)") }
            else                     { GifView(fileName: "\(TipInfo.tips[tiptype.rawValue].fileName)_\(colorScheme)") }
        }
        .modifier(TipModifier(order: tiptype.rawValue))
    }
}
