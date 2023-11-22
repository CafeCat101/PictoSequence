//
//  MyImage.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/11/22.
//

import Foundation
import SwiftUI

struct MyImage: Identifiable {
	let id = UUID()
	var image:Image
	var localPicturePath:String = ""
}
