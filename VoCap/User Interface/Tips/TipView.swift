//
//  TipView.swift
//  VoCap
//
//  Created by 윤태민 on 7/30/21.
//

import SwiftUI

struct TipView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let order: Int
    @Binding var tipControls: [TipControl]
    
    var body: some View {
        Group {
            if tipControls[order].isPresented {
                Rectangle()
                    .fill(Color.black.opacity(0.4))
                    .ignoresSafeArea()
                    .overlay(
                        Button(action: { tipControls[order].makeTipDisabled() }) {
                            tip
                        }
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
    var tip: some View {
        ZStack {
//            // Tip 띄어진 상태에서 mode 변경하면 반영 안 됨
//            GifView(fileName: "\(TipInfo.fileNames[info.order])_\(colorScheme)")
            
            if colorScheme == .light { GifView(fileName: "\(TipInfo.fileNames[order])_\(colorScheme)") }
            else                     { GifView(fileName: "\(TipInfo.fileNames[order])_\(colorScheme)") }
        }
        .modifier(TipModifier(order: order))
    }
}
