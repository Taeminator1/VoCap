//
//  HowToGlanceView.swift
//  VoCap
//
//  Created by 윤태민 on 3/3/21.
//

import SwiftUI

//struct HowToGlanceView: View {
//    let size: CGSize?
//
//    init(size: CGSize? = nil) {
//        self.size = size
//    }
//
//    var body: some View {
//        GeometryReader { _ in
//            Rectangle()
//                .frame(width: self.size?.width ?? $0.size.width * 0.6,
//                       height: self.size?.height ?? $0.size.height * 0.25)
//                .cornerRadius(12)
//                .position(x: UIScreen.main.bounds.width / 2,
//                          y: UIScreen.main.bounds.height / 2)
//        }
//    }
//}

struct HowToGlanceView: View {
//    let width: CGFloat = 200
//    let height: CGFloat = 432.85
    
    let width: CGFloat = 200
    let height: CGFloat = 200
    
    var body: some View {
        ZStack {
            Rectangle()
                .colorInvert()
                
            GifView(fileName: "HowToGlance")
        }
        .frame(width: width, height: height)
        .cornerRadius(12)
        
    }
}

struct HowToGlanceView_Previews: PreviewProvider {
    static var previews: some View {
        HowToGlanceView()
    }
}
