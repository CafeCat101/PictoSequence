//
//  APictureCardView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/11/4.
//

import SwiftUI

struct APictureCardView: View {
	//var word:String = "pic"
	@EnvironmentObject var sequencer:Sequencer
	@Environment(\.colorScheme) var colorScheme
	
	@State var wordCard:WordCard = WordCard()
	var picWidth:CGFloat = 200
	var picHeight:CGFloat = 200
	var fromDatabase = false
	
	@State private var showPic = true
	@State private var sourceType:PictureSource = .icon
	@State private var showPhotoPicker = false
	@State private var showCaptureView = false
	@StateObject private var cameraDataModel = DataModel()
	@StateObject private var viewModel = PictureModel()
	@State private var editingCount = 0
	@State private var selectedChangedPhoto:Image?
	
	
	var body: some View {
		VStack {
			pictureContainer()
				.modifier(photoStyle(getPicWidth: picWidth, getPicHeight: picHeight))
				.onTapGesture {
					showPic = false
				}
				.opacity(showPic ? 1 : 0)
				.disabled(showPic ? false : true)
				.onReceive(viewModel.transferableDone, perform: { result in
					print("[debug] APictureCardView, onRecieve viewModel.transferableDone \(viewModel.selectToUse)")
					if result == true && viewModel.selectToUse == true {
						selectedChangedPhoto = viewModel.selectedImage
						cameraDataModel.thumbnailImage = nil
						sourceType = .photoPicker
						wordCard.pictureID = UUID()
						wordCard.pictureLocalPath = "pictures/\(wordCard.pictureID.uuidString).jpg"
						wordCard.pictureType = .photoPicker
						wordCard.photo = UIImage(data: viewModel.selectedImageData!)
						
						let findCardIndex = sequencer.theStoryByUser.visualizedSequence.firstIndex(where: {$0.word == wordCard.word}) ?? -1
						if findCardIndex > -1 {
							sequencer.theStoryByUser.visualizedSequence[findCardIndex] = wordCard
						}
					}
				})
				.onReceive(cameraDataModel.capturedImageDone, perform: {result in
					selectedChangedPhoto = cameraDataModel.thumbnailImage
					wordCard.pictureID = UUID()
					wordCard.pictureLocalPath = "pictures/\(wordCard.pictureID.uuidString).jpg"
					wordCard.pictureType = .camera
					wordCard.photo = UIImage(data: cameraDataModel.thumbnailImageData!)
					
					let findCardIndex = sequencer.theStoryByUser.visualizedSequence.firstIndex(where: {$0.word == wordCard.word}) ?? -1
					if findCardIndex > -1 {
						sequencer.theStoryByUser.visualizedSequence[findCardIndex] = wordCard
					}
				})
		}
		.overlay(content: {
			if showPic == false {
				VStack(spacing:0) {
					Spacer()
					HStack(spacing:0){
						Spacer()
						Text(wordCard.word)
							.font(.headline)
							.padding()
							.foregroundColor(.white)
						Spacer()
					}
					Spacer()
				}
				.frame(minWidth: picWidth, minHeight: picHeight)
				.background {
					RoundedRectangle(cornerRadius: 15)
						.foregroundColor(.black)
				}
				.onTapGesture {
					showPic = true
				}
				.opacity(showPic ? 0 : 1)
				.disabled(showPic ? true : false)
			}
		})
		.contextMenu(ContextMenu(menuItems: {
			if sourceType != .icon {
				Button(action: {
					selectedChangedPhoto = nil
					viewModel.selectedImage = nil
					cameraDataModel.thumbnailImage = nil
					sourceType = .icon
					
					wordCard.pictureID = UUID()
					wordCard.pictureLocalPath = "pictures/\(sequencer.getImageFileName(remoteURL: wordCard.iconURL))"
					wordCard.pictureType = .icon
					
					let findCardIndex = sequencer.theStoryByUser.visualizedSequence.firstIndex(where: {$0.word == wordCard.word}) ?? -1
					if findCardIndex > -1 {
						sequencer.theStoryByUser.visualizedSequence[findCardIndex] = wordCard
					}
				}, label: {
					Text("Use icon")
				})
			}
			
			Button(action: {
				viewModel.selectToUse = true
				showPhotoPicker.toggle()
			}, label: {
				Text("Select a photo")
			})
			
			Button(action: {
				showCaptureView = true
			}, label: {
				Text("Take a new photo")
			})
		}))
		.photosPicker(isPresented: $showPhotoPicker ,selection: $viewModel.imageSelection, matching: .any(of: [.images, .livePhotos]))
		.fullScreenCover(isPresented: $showCaptureView, content: {
			CameraView(model:cameraDataModel, showCaptureView: $showCaptureView, viewModel: viewModel, sourceType: $sourceType)
		})
	}
	
	struct photoStyle: ViewModifier {
		@Environment(\.colorScheme) var colorScheme
		var getPicWidth: CGFloat = 200
		var getPicHeight: CGFloat = 200
		
		func body(content: Content) -> some View {
			content
				.frame(width: getPicWidth, height: getPicHeight)
				.clipShape(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15)))
				.background {
					RoundedRectangle(cornerRadius: 15)
						.foregroundColor(Color("word_icon_bg"))
						.opacity(colorScheme == .dark ? 0.5 : 0.8)
						.shadow(color: .black, radius: 5)
				}
		}
	}
	
	@ViewBuilder
	private func pictureContainer() -> some View {
		if selectedChangedPhoto != nil {
			selectedChangedPhoto!
				.resizable()
				.scaledToFill()
		} else {
			displayImageFromFile()
		}
	}
	
	@ViewBuilder
	private func displayImageFromFile() -> some View {
		if pictureExists(localPath: wordCard.pictureLocalPath) {
			let pictureURL = FileManager.documentoryDirecotryURL.appending(component: wordCard.pictureLocalPath)
			if wordCard.pictureType == .icon {
				Image(uiImage: UIImage(contentsOfFile: pictureURL.path())!)
					.resizable()
					.scaledToFit()
					.padding()
					.onAppear(perform: {
						print("[debug] APictureCardView, displayImageFromFile, onAppear (fileExists \(wordCard.word)) \(wordCard.pictureLocalPath)")
					})
					.onChange(of: wordCard, perform: { wordCard in
						print("[debug] APictureCardView, displayImageFromFile, onChange (fileExists \(wordCard.word)) \(wordCard.pictureLocalPath)")
					})
			} else {
				Image(uiImage: UIImage(contentsOfFile: pictureURL.path())!)
					.resizable()
					.scaledToFill()
					.onAppear(perform: {
						print("[debug] APictureCardView, displayImageFromFile, onAppear (fileExists \(wordCard.word)) \(wordCard.pictureLocalPath)")
					})
					.onChange(of: wordCard, perform: { wordCard in
						print("[debug] APictureCardView, displayImageFromFile, onChange (fileExists \(wordCard.word)) \(wordCard.pictureLocalPath)")
					})
			}
			
		} else {
			AsyncImage(url: URL(string: wordCard.iconURL)) { phase in
				if let image = phase.image {
					image
						.resizable()
						.scaledToFit()
						.padding()
						.onAppear(perform: {
							print("[debug] APictureCardView, displayImageFromFile, AsyncImage.onAppear, word \(wordCard.word) \(wordCard.pictureLocalPath)")
						})
				} else if phase.error != nil {
					Text("There was an error loading the image.")
				} else {
					ProgressView()
						.onAppear(perform: {
							print("[debug] APictureCardView, displayImageFromFile, AsyncImage-ProgressView() word \(wordCard.word) \(wordCard.pictureLocalPath)")
						})
				}
			}
		}
	}
	
	private func pictureExists(localPath: String) -> Bool {
		//localPath is wordCard.pictureLocalPath
		let imageUrl = FileManager.documentoryDirecotryURL.appending(path: localPath)
		if FileManager.default.fileExists(atPath: imageUrl.path()) {
			return true
		} else {
			return false
		}
	}
}

/*#Preview {
 APictureCardView()
 }*/
