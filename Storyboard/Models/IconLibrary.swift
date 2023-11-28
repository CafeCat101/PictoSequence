//
//  IconLibrary.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/11/26.
//

import Foundation
import Combine

final class IconLibrary: ObservableObject {
	var savedPictures:[MyImage] = []
	var pictureSelected = PassthroughSubject<MyImage, Never>()
}
