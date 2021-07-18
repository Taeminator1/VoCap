//
//  HowToDoSomethingView.swift
//  VoCap
//
//  Created by 윤태민 on 3/18/21.
//

import SwiftUI

struct HowToDoSomethingView: View {
    @Environment(\.colorScheme) var colorScheme
    var tipInfo: TipInfo = TipInfo()
    
    var body: some View {
        ZStack {
//            GifView(fileName: "\(TipInfo.fileNames[tipInfo.order])_\(colorScheme)")     // Tip 띄어진 상태에서 mode 변경하면 반영 안 됨
            
            if colorScheme == .light    { GifView(fileName: "\(TipInfo.fileNames[tipInfo.order])_\(colorScheme)") }
            else                        { GifView(fileName: "\(TipInfo.fileNames[tipInfo.order])_\(colorScheme)") }
        }
        .frame(width: TipInfo.viewSizes[tipInfo.order].width, height: TipInfo.viewSizes[tipInfo.order].height)
        .cornerRadius(12)
    }
}

struct HowToDoSomethingView_Previews: PreviewProvider {
    static var previews: some View {
        HowToDoSomethingView()
    }
}
