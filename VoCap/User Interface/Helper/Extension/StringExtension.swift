//
//  StringExtension.swift
//  VoCap
//
//  Created by 윤태민 on 3/15/21.
//

//  https://zeddios.tistory.com/368 [ZeddiOS]
//  NSLocalizedString("abc", comment: "")
//  -> "abc".localized()            // 함수 이용
//  -> "abc".localized              // 연산 프로퍼티 이용

import Foundation

extension String {
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
    
    var localized: String {
        return NSLocalizedString(self, tableName: "Localizable", value: self, comment: "")
    }
}
