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
	var picture:Image = Image(systemName: "photo.circle.fill")
	var pictureType: PictureSource = .icon
	var iconURL = ""
}
