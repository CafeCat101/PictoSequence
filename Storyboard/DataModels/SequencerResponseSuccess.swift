//
//  SequencerResponseSuccess.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/10/2.
//

import Foundation

struct SequencerResponseSuccess: Decodable, Hashable {
	let type: String
	let word: [String]
	let synonyms: [String]
}
