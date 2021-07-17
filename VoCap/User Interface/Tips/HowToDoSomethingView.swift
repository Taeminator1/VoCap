//
//  HowToDoSomethingView.swift
//  VoCap
//
//  Created by 윤태민 on 3/18/21.
//

import SwiftUI

struct HowToDoSomethingView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var width: CGFloat = 100.0
    var height: CGFloat = 100.0
    
    let fileName: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .colorInvert()
                
            if colorScheme == .light {
                GifView(fileName: String("\(fileName)_Light"))
            }
            else {
                GifView(fileName: String("\(fileName)_Dark"))
            }
            
        }
        .frame(width: width, height: height)
        .cornerRadius(12)
    }
}

struct HowToDoSomethingView_Previews: PreviewProvider {
    static var previews: some View {
        HowToDoSomethingView(width: 1000, height: 100, fileName: "test")
    }
}
