//
//  TrainingData.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/10/1.
//

import Foundation

struct TrainingData: Codable {
		let question: String
		let answer: [WordData]
		
		enum CodingKeys: String, CodingKey {
				case question = "Question"
				case answer = "Answer"
		}
}

struct WordData: Codable {
		let type: WordType
		let word: [String]
		let synonyms: [String]
}
