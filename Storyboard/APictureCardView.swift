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
				if result == true && showCaptureView == false {
					cameraDataModel.thumbnailImage = nil
					sourceType = .photoPicker
				}
			})
			.onReceive(cameraDataModel.capturedImageDone, perform: {result in
				/*let findCardIndex = sequencer.theStoryByUser.visualizedSequence.firstIndex(where: {$0.word == wordCard.word}) ?? -1
				let newPicID = UUID()
				sequencer.theStoryByUser.visualizedSequence[findCardIndex].pictureID = newPicID
				let toUIImage = UIImage(data: viewModel.selectedImageData!)
				sequencer.theStoryByUser.visualizedSequence[findCardIndex].pictureLocalPath = saveJpg(saveImage: toUIImage!, imageFileName: newPicID.uuidString)*/
				viewModel.selectedImage = nil
				sourceType = .camera
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
					viewModel.selectedImage = nil
					cameraDataModel.thumbnailImage = nil
					sourceType = .icon
				}, label: {
					Text("Use icon")
				})
			}
			
			Button(action: {
				showPhotoPicker.toggle()
				//sourceType = .photoPicker
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
	
	private func saveJpg(saveImage: UIImage, imageFileName: String) -> String {
		let jpgData = saveImage.jpegData(compressionQuality: 0.6)
		let saveToURL = URL(fileURLWithPath: imageFileName, relativeTo: FileManager.pictureDirectoryURL).appendingPathExtension("jpg")
		try? jpgData!.write(to: saveToURL)
		return "pictures/\(imageFileName).jpg"
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
		//if sourceType == .icon {
		//	displayImageFromFile()
		//} else {
			if viewModel.selectedImage != nil || cameraDataModel.thumbnailImage != nil {
				if viewModel.selectedImage != nil {
					switch viewModel.imageState {
					case .success(let image):
						image
							.resizable()
							.scaledToFill()
					case .loading:
						ProgressView()
					case .empty:
						Image(systemName: "circle.badge.questionmark.fill")
							.scaledToFit()
							.padding()
					case .failure:
						Image(systemName: "exclamationmark.triangle.fill")
							.scaledToFit()
							.padding()
					}
				} else if cameraDataModel.thumbnailImage != nil {
					cameraDataModel.thumbnailImage?
						.resizable()
						.scaledToFill()
				}
			} else {
				displayImageFromFile()
			}
		//}
		
	}
	
	@ViewBuilder
	private func displayImageFromFile() -> some View {
		if FileManager.default.fileExists(atPath: wordCard.pictureLocalPath) {
			let pictureURL = URL(string: wordCard.pictureLocalPath, relativeTo: FileManager.documentoryDirecotryURL)!
			Image(uiImage: UIImage(contentsOfFile: pictureURL.absoluteString)!)
				.onAppear(perform: {
					print("[debug] APictureCardView, pictureContainer, pictureLocalPath \(wordCard.pictureLocalPath)")
				})
				.onChange(of: wordCard, perform: { wordCard in
					print("[debug] APictureCardView, pictureContainer, photo-pictureLocalPath \(wordCard.pictureLocalPath)")
				})
		} else {
			AsyncImage(url: URL(string: wordCard.iconURL)) { phase in
				if let image = phase.image {
					image
						.resizable()
						.scaledToFit()
						.padding()
						.onAppear(perform: {
							print("[debug] APictureView, AsyncImage.onAppear, word \(wordCard.word)")
						})
				} else if phase.error != nil {
					Text("There was an error loading the image.")
				} else {
					ProgressView()
				}
			}
		}
	}
}

/*#Preview {
	APictureCardView()
}*/
