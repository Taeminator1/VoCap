//
//  LexicalaEntry.swift
//  VoCap
//
//  Created by 윤태민 on 12/2/20.
//

import Foundation

struct LexicalaEntry: Codable {
    let id, source, language: String
    let headword: DataHeadword
    let senses: [DataSense]
    let relatedEntries: [String]

    enum CodingKeys: String, CodingKey {
        case id, source, language, headword, senses
        case relatedEntries = "related_entries"
    }
}

struct DataHeadword: Codable {
    let text: String
    let pronunciation: DataPronunciation
    let pos: String
}

struct DataPronunciation: Codable {
    let value: String
}

struct DataSense: Codable {
    let id, definition: String
    let translations: [String: DataExample]
    let examples: [DataExample]
}

struct DataExample: Codable {
    let text: String
}

