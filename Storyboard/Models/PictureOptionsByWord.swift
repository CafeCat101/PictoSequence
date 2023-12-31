//
//  MySavedPictures.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/11/22.
//

import Foundation
import Combine
import SwiftUI

final class PictureOptionsByWord: ObservableObject {
	@Published var availablePictures:[MyImage] = []
	var pictureSelected = PassthroughSubject<MyImage, Never>()
}
