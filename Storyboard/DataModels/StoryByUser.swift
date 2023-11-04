//
//  StoryByUser.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/10/29.
//

import Foundation
import SwiftUI

struct StoryByUser {
	var sentence = ""
	var visualizedSequence:[WordCard] = []
}

struct WordCard: Identifiable {
	var id = UUID()
	var word = ""
	var picture:Image?
	var pictureType: PictureSource = .icon
	var iconURL = ""
}
