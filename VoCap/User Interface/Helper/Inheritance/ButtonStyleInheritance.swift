//
//  ButtonStyleInheritance.swift
//  VoCap
//
//  Created by 윤태민 on 1/17/21.
//

import Foundation
import SwiftUI

struct NoEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
    }
}
