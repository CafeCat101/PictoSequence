//
//  MyImage.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/11/22.
//

import Foundation
import SwiftUI

struct MyImage: Identifiable {
	var id = UUID()
	var image:UIImage?
	var localPicturePath:String = ""
	var pictureType:PictureSource = .icon
}
