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
	//@ObservedObject var viewModel: PictureModel
	//@Binding var showPhotoPicker:Bool
	//@State private var useIcon = true
	@State private var sourceType:PictureSource = .icon
	
	@StateObject var viewModel = PictureModel()
	@State private var showPhotoPicker = false
	@State private var showCaptureView = false
	@StateObject private var cameraDataModel = DataModel()
	
	
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
				.frame(width: picWidth, height: picHeight)
				.onTapGesture {
					showPic = false
				}
				.opacity(showPic ? 1 : 0)
				.disabled(showPic ? false : true)
			} else if sourceType == .photoPicker {
				switch viewModel.imageState {
				case .success(let image):
					image.resizable()
						.scaledToFit()
						 .padding()
						 .opacity(showPic ? 1 : 0)
						 .disabled(showPic ? false : true)
				case .loading:
					ProgressView()
						.opacity(showPic ? 1 : 0)
						.disabled(showPic ? false : true)
				case .empty:
					Image(systemName: "circle.badge.questionmark.fill")
						.scaledToFit()
						.padding()
						.foregroundColor(.white)
						.opacity(showPic ? 1 : 0)
						.disabled(showPic ? false : true)
				case .failure:
					Image(systemName: "exclamationmark.triangle.fill")
						.font(.system(size: 40))
						.foregroundColor(.white)
						.opacity(showPic ? 1 : 0)
						.disabled(showPic ? false : true)
				}
			} else if sourceType == .camera {
				/*cameraDataModel.thumbnailImage?
					.resizable()
					.scaledToFill()
					.frame(width: picWidth, height: picHeight)
					.clipShape(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15)))
					.onTapGesture {
						showPic = false
					}
					.opacity(showPic ? 1 : 0)
					.disabled(showPic ? false : true)*/
				Image(systemName: "circle.badge.questionmark")
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
					RoundedRectangle(cornerRadius: 10)
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
			if result == true {
				sourceType = .photoPicker
			}
		})
		.photosPicker(isPresented: $showPhotoPicker ,selection: $viewModel.imageSelection, matching: .any(of: [.images, .livePhotos]))
		.fullScreenCover(isPresented: $showCaptureView, content: {
			CameraView(showCaptureView: $showCaptureView)
		})
		
		
		
		/*if showPic {
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
		 .frame(width: picWidth, height: picHeight)
		 .onTapGesture {
		 showPic = false
		 }
		 } else {
		 Text(word)
		 .font(.headline)
		 .padding()
		 .frame(minWidth: picWidth, minHeight: picHeight)
		 .onTapGesture {
		 showPic = true
		 }
		 }*/
		
	}
	
	
}

#Preview {
	APictureView()
}
