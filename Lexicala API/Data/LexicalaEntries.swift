//
//  LexicalaEntries.swift
//  VoCap
//
//  Created by 윤태민 on 12/2/20.
//

import Foundation

struct LexicalaEntries: Codable {
    let nResults, pageNumber, resultsPerPage, nPages, availableNPages: Int?
    let results: [EntriesResult]?

    enum CodingKeys: String, CodingKey {
        case nResults = "n_results"
        case pageNumber = "page_number"
        case resultsPerPage = "results_per_page"
        case nPages = "n_pages"
        case availableNPages = "available_n_pages"
        case results
    }
}

struct EntriesResult: Codable {
    let id, language: String?
    let headword: EntriesHeadword?
    let senses: [EntriesSense]?
}

struct EntriesHeadword: Codable {
    let text, pos: String?
}

struct EntriesSense: Codable {
    let id, definition: String?
}
