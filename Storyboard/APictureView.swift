//
//  APictureView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/10/8.
//

import SwiftUI
import PhotosUI

struct APictureView: View {
	var word:String = "pic"
	var urlStr:String = "https://static.thenounproject.com/png/5222984-200.png"
	var picWidth:CGFloat = 200
	var picHeight:CGFloat = 200
	@State private var showPic = true
	@State private var sourceType:PictureSource = .icon
	
	@StateObject var viewModel = PictureModel()
	@State private var showPhotoPicker = false
	@State private var showCaptureView = false
	@StateObject private var cameraDataModel = DataModel()
	@Environment(\.colorScheme) var colorScheme
	
	
	var body: some View {
		VStack {
			if sourceType == .icon {
				AsyncImage(url: URL(string: urlStr)) { phase in
					if let image = phase.image {
						image
							.resizable()
							.scaledToFit()
							.padding()
					} else if phase.error != nil {
						Text("There was an error loading the image.")
					} else {
						ProgressView()
					}
				}
				.modifier(photoStyle(getPicWidth: picWidth, getPicHeight: picHeight))
				.onTapGesture {
					showPic = false
				}
				.opacity(showPic ? 1 : 0)
				.disabled(showPic ? false : true)
			} else if sourceType == .photoPicker {
				switch viewModel.imageState {
				case .success(let image):
					image
						.resizable()
						.scaledToFill()
						.modifier(photoStyle(getPicWidth: picWidth, getPicHeight: picHeight))
						 .opacity(showPic ? 1 : 0)
						 .disabled(showPic ? false : true)
						 .onTapGesture {
							 showPic = false
						 }
						 
				case .loading:
					ProgressView()
						.opacity(showPic ? 1 : 0)
						.disabled(showPic ? false : true)
				case .empty:
					Image(systemName: "circle.badge.questionmark.fill")
						.scaledToFit()
						.padding()
						.opacity(showPic ? 1 : 0)
						.disabled(showPic ? false : true)
				case .failure:
					Image(systemName: "exclamationmark.triangle.fill")
						.scaledToFit()
						.padding()
						.opacity(showPic ? 1 : 0)
						.disabled(showPic ? false : true)
				}
			} else if sourceType == .camera {
				cameraDataModel.thumbnailImage?
					.resizable()
					.scaledToFill()
					.modifier(photoStyle(getPicWidth: picWidth, getPicHeight: picHeight))
					.onTapGesture {
						showPic = false
					}
					.opacity(showPic ? 1 : 0)
					.disabled(showPic ? false : true)
			} else {
				Image(systemName: "circle.badge.questionmark")
			}
		}
		.overlay(content: {
			if showPic == false {
				VStack(spacing:0) {
					Spacer()
					HStack(spacing:0){
						Spacer()
						Text(word)
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
		.onReceive(viewModel.transferableDone, perform: { result in
			if result == true && showCaptureView == false {
				sourceType = .photoPicker
			}
		})
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
}

#Preview {
	APictureView()
}
