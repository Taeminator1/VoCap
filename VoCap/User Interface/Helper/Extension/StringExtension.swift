//
//  StringExtension.swift
//  VoCap
//
//  Created by 윤태민 on 3/15/21.
//

//  Extension for localizing:
//  - NSLocalizedString("abc", comment: "")
//  - "abc".localized              // Using computed Property.

//  Reference: https://zeddios.tistory.com/368

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: "Localizable", value: self, comment: "")
    }
}
