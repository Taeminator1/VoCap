//
//  TipControl.swift
//  VoCap
//
//  Created by 윤태민 on 8/7/21.
//

//  Offer various methods to control tip.
//  - reset: Make user default false

import Foundation

struct TipControl {
    private var tipType: TipType
    private var isDisabled: Bool = false
    private var userDefault: Bool {
        get { UserDefaults.standard.bool(forKey: "tip\(tipType.rawValue)") }
        set { UserDefaults.standard.set(newValue, forKey: "tip\(tipType.rawValue)") }
    }
    var isPresented: Bool { self.isDisabled && !self.userDefault }
    
    init(_ tipType: TipType) {
        self.tipType = tipType
    }
    
    func reset() {
        UserDefaults.standard.set(false, forKey: "tip\(tipType.rawValue)")
    }
    
    mutating func makeTipDisabled() {
        self.userDefault = true
        makeViewDisabled()
    }
    
    mutating func makeViewEnabled() {
        self.isDisabled = false
    }
    
    mutating func makeViewDisabled() {
        self.isDisabled = true
    }
    
    mutating func makeViewToggle() {
        self.isDisabled = self.isDisabled ? false : true
    }
}
