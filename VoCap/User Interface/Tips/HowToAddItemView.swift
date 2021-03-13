//
//  HowToAddItemView.swift
//  VoCap
//
//  Created by 윤태민 on 3/12/21.
//

import SwiftUI

struct HowToAddItemView: View {
    @Environment(\.colorScheme) var colorScheme
    
    // Original Size: 300 x 350
    let width: CGFloat = 300
    let height: CGFloat = 350
    
    var body: some View {
        ZStack {
            Rectangle()
                .colorInvert()
                
            if colorScheme == .light {
                GifView(fileName: "HowToAddItem_Light")
            }
            else {
                GifView(fileName: "HowToAddItem_Dark")
            }
            
        }
        .frame(width: width, height: height)
        .cornerRadius(12)
    }
}

struct HowToAddItemView_Previews: PreviewProvider {
    static var previews: some View {
        HowToAddItemView()
    }
}
