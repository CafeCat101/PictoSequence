//
//  TrainingModel.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/10/1.
//

import Foundation

struct TrainingModel: Codable {
	let model:String
	let system: String
	let training: [TrainingData]
	
	enum CodingKeys: String, CodingKey {
		case model = "Model"
		case system = "System"
		case training = "Training"
	}
	
	init() {
		model = ""
		system = ""
		training = []
	}
}
