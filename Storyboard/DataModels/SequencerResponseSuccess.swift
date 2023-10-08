//
//  SequencerResponseSuccess.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/10/2.
//

import Foundation

struct SequencerResponseSuccess: Codable, Hashable {
	let type: String
	let words: [WordData]
}

struct WordData: Codable, Hashable {
		let word: String
		let synonyms: [String]
	let pictures:[WordPicture]
}

struct WordPicture: Codable, Hashable {
	let name: String
	let tags: String
	let thumbnail_url: String
}
