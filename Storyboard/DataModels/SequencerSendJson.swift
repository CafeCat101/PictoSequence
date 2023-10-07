//
//  SequencerSendJson.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/10/1.
//

import Foundation

struct SequencerSendJsonObject: Encodable {
	var server_validation: Int = 0
	var user_question: String = ""
}
