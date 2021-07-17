//
//  GifView.swift
//  VoCap
//
//  Created by 윤태민 on 3/3/21.
//

import SwiftUI
import FLAnimatedImage

struct GifView: UIViewRepresentable {
    let animatedView = FLAnimatedImageView()
    var fileName: String
    func makeUIView(context: UIViewRepresentableContext<GifView>) -> UIView {
        let view = UIView()
        
//        guard let path: String = Bundle.main.path(forResource: fileName, ofType: "gif") else {
//            return view
//        }
        
        let path: String = Bundle.main.path(forResource: fileName, ofType: "gif")!
        let url = URL(fileURLWithPath: path)
        let gifData = try! Data(contentsOf: url)
        
        let gif = FLAnimatedImage(animatedGIFData: gifData)
        animatedView.animatedImage = gif
        
        animatedView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animatedView)
        
        NSLayoutConstraint.activate([
            animatedView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animatedView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<GifView>) {
        
    }
}
