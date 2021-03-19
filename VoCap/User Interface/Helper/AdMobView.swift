//
//  AdMobView.swift
//  VoCap
//
//  Created by 윤태민 on 3/13/21.
//

import SwiftUI
import UIKit
import GoogleMobileAds

// Test baner adUnitID: "ca-app-pub-3940256099942544/2934735716"
// VoCap baner adUnitID: "ca-app-pub-1173596179673040/5837435794"
struct GADBannerViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let view = GADBannerView(adSize: kGADAdSizeBanner)
        let viewController = UIViewController()
        
//        view.adUnitID = "ca-app-pub-3940256099942544/2934735716"            // for Test
        view.adUnitID = "ca-app-pub-1173596179673040/5837435794"            // for Release
        view.rootViewController = viewController
        viewController.view.addSubview(view)
        viewController.view.frame = CGRect(origin: .zero, size: kGADAdSizeBanner.size)
        view.load(GADRequest())
        
        return viewController
    }
 
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}

//struct AdMobView: View {
//    var body: some View {
//        GADBannerViewController()
//            .frame(width: kGADAdSizeBanner.size.width, height: kGADAdSizeBanner.size.height)
//    }
//}
//
//struct AdMobView_Previews: PreviewProvider {
//    static var previews: some View {
//        AdMobView()
//    }
//}
