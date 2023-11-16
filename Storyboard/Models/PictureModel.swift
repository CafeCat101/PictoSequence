//
//  PictureModel.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/10/11.
//

import Foundation
import SwiftUI
import PhotosUI
import CoreTransferable
import Combine

@MainActor
class PictureModel: ObservableObject {
	var transferableDone = PassthroughSubject<Bool, Never>()
	var selectedImage: Image?
	var selectedImageData: Data?
	var selectToUse:Bool = true //true is click on the photo means use it right away.
	
	enum ImageState {
		case empty
		case loading(Progress)
		case success(Image)
		case failure(Error)
	}
	
	enum TransferError: Error {
		case importFailed
	}
	
	struct WordImage: Transferable {
		let image: Image
		let imageData: Data
		
		
		static var transferRepresentation: some TransferRepresentation {
			DataRepresentation(importedContentType: .image) { data in
#if canImport(AppKit)
				guard let nsImage = NSImage(data: data) else {
					throw TransferError.importFailed
				}
				let image = Image(nsImage: nsImage)
				return WordImage(image: image, imageData: data)
#elseif canImport(UIKit)
				guard let uiImage = UIImage(data: data) else {
					throw TransferError.importFailed
				}
				let image = Image(uiImage: uiImage)
				return WordImage(image: image, imageData: data)
#else
				throw TransferError.importFailed
#endif
			}
		}
	}
	
	@Published private(set) var imageState: ImageState = .empty
	
	@Published var imageSelection: PhotosPickerItem? = nil {
		didSet {
			if let imageSelection {
				let progress = loadTransferable(from: imageSelection)
				imageState = .loading(progress)
				//self.transferableDone.send(true)
			} else {
				imageState = .empty
			}
		}
	}
	
	// MARK: - Private Methods
	
	private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
		return imageSelection.loadTransferable(type: WordImage.self) { result in
			DispatchQueue.main.async {
				guard imageSelection == self.imageSelection else {
					print("Failed to get the selected item.")
					return
				}
				switch result {
				case .success(let profileImage?):
					self.imageState = .success(profileImage.image)
					self.selectedImage = profileImage.image
					self.selectedImageData = profileImage.imageData
					self.transferableDone.send(true)
				case .success(nil):
					self.imageState = .empty
				case .failure(let error):
					self.imageState = .failure(error)
					self.transferableDone.send(false)
				}
			}
		}
	}
	
	func sendTransferableDone() {
		if self.selectedImage != nil {
			self.transferableDone.send(true)
		} else {
			self.transferableDone.send(false)
		}
		
	}
}
