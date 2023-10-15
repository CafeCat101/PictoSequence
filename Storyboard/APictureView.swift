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
	@State private var useIcon = true
	
	@StateObject var viewModel = PictureModel()
	@State private var showPhotoPicker = false
	@State private var showCaptureView = false
	
	
	var body: some View {
		VStack {
			if useIcon {
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
					Button(action: {
						showPhotoPicker.toggle()
						useIcon = false
					}, label: {
						Text("Select a photo")
					})
					
					Button(action: {
						showCaptureView = true
					}, label: {
						Text("Take a new photo")
					})
					
				}))
			} else {
				switch viewModel.imageState {
				case .success(let image):
					image.resizable()
						.scaledToFit()
						 .padding()
				case .loading:
					ProgressView()
				case .empty:
					Image(systemName: "circle.badge.questionmark.fill")
						.scaledToFit()
						.padding()
						.foregroundColor(.white)
				case .failure:
					Image(systemName: "exclamationmark.triangle.fill")
						.font(.system(size: 40))
						.foregroundColor(.white)
				}
			}
		}
		.photosPicker(isPresented: $showPhotoPicker ,selection: $viewModel.imageSelection, matching: .any(of: [.images, .livePhotos]))
		.fullScreenCover(isPresented: $showCaptureView, content: {
			CameraView()
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
