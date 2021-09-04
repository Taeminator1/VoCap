//
//  AdMobView.swift
//  VoCap
//
//  Created by 윤태민 on 3/13/21.
//

import SwiftUI
import UIKit
import GoogleMobileAds

struct GADBannerViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let view = GADBannerView(adSize: kGADAdSizeBanner)
        let viewController = UIViewController()

        
        view.adUnitID = PersonalInfo.adUnitID
        view.rootViewController = viewController
        viewController.view.addSubview(view)
        viewController.view.frame = CGRect(origin: .zero, size: kGADAdSizeBanner.size)
        view.load(GADRequest())
        
        return viewController
    }
 
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}
