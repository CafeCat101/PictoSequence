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

struct WordCard: Identifiable, Equatable {
	var id = UUID()
	var word = ""
	var cardOrder = 0
	var pictureID = UUID()
	var pictureType: PictureSource = .icon
	var pictureLocalPath = ""
	var photo:UIImage? //to hold the selected photopicker image or camera captured image for resizing before saving them
	var iconURL = ""
}
