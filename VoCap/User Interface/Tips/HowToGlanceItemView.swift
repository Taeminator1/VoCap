//
//  HowToGlanceItemView.swift
//  VoCap
//
//  Created by 윤태민 on 3/3/21.
//

import SwiftUI

struct HowToGlanceItemView: View {
    @Environment(\.colorScheme) var colorScheme
    
    // Original Size: 400 x 300
    let width: CGFloat = 280
    let height: CGFloat = 210
    
    var body: some View {
        ZStack {
            Rectangle()
                .colorInvert()
                
            if colorScheme == .light {
                GifView(fileName: "HowToGlanceItem_Light")
            }
            else {
                GifView(fileName: "HowToGlanceItem_Dark")
            }
            
        }
        .frame(width: width, height: height)
        .cornerRadius(12)
    }
}

struct HowToGlanceItemView_Previews: PreviewProvider {
    static var previews: some View {
        HowToGlanceItemView()
    }
}
