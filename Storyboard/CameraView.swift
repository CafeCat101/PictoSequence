//
//  CameraView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/10/15.
//

import SwiftUI
import PhotosUI

struct CameraView: View {
	@StateObject private var model = DataModel()
	
	private static let barHeightFactor = 0.15
	@Binding var showCaptureView:Bool
	//@StateObject var viewModel = PictureModel()
	@ObservedObject var viewModel:PictureModel
	@Binding var sourceType:PictureSource
	@State private var showPickerSelectedPhoto = false
	
	
	var body: some View {
		
		
		GeometryReader { geometry in
			ViewFinderView(image:  $model.viewfinderImage )
				.overlay(alignment: .top) {
					/*Color.black
					 .opacity(0.75)
					 .frame(height: geometry.size.height * Self.barHeightFactor)*/
					VStack {
						Spacer()
						HStack {
							Button(action: {
								model.camera.isPreviewPaused = true
								showCaptureView = false
							}, label: {
								Label(
									title: { Text("Cancel") },
									icon: { Image(systemName: "xmark") }
								)
								.labelStyle(.titleOnly)
								.bold()
								.foregroundStyle(.white)
							})
							Spacer()
							Button(action: {
								if model.thumbnailImage != nil {
									sourceType = .camera
								} else if showPickerSelectedPhoto == true {
									sourceType = .photoPicker
								}
								showCaptureView = false
							}, label: {
								Label(
									title: { Text("Use") },
									icon: { Image(systemName: "checkmark") }
								).labelStyle(.titleOnly).bold()
							})
							.foregroundStyle(model.thumbnailImage == nil ? .gray : .white)
							.disabled(model.thumbnailImage == nil ? true : false)
						}
						.padding([.leading,.trailing], 15)
						Spacer()
					}
					.frame(height: geometry.size.height * Self.barHeightFactor)
					.background(
						Rectangle()
							.foregroundColor(.black)
							.opacity(model.thumbnailImage == nil ? 0.75 : 0.85)
					)
					
				}
				.overlay(alignment: .bottom) {
					buttonsView()
						.frame(height: geometry.size.height * Self.barHeightFactor)
						.background(.black.opacity(model.thumbnailImage == nil ? 0.75 : 0.85))
				}
				.overlay(alignment: .center)  {
					if showPickerSelectedPhoto == false {
						if model.thumbnailImage == nil {
							Color.clear
								.frame(height: geometry.size.height * (1 - (Self.barHeightFactor * 2)))
								.accessibilityElement()
								.accessibilityLabel("View Finder")
								.accessibilityAddTraits([.isImage])
						} else {
							VStack {
								HStack {
									Spacer()
									model.thumbnailImage?
										.resizable()
										.scaledToFill()
										.frame(width: geometry.size.width-50, height: geometry.size.width-50)
										.clipShape(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15)))
										.shadow(color: .black, radius: 20)
									Spacer()
								}
							}
							.frame(height: geometry.size.height * (1 - (Self.barHeightFactor * 2)))
							.background(Rectangle().foregroundStyle(.black).opacity(0.85))
						}
					} else {
						VStack {
							HStack {
								Spacer()
								viewModel.selectedImage?
									.resizable()
									.scaledToFill()
									.frame(width: geometry.size.width-50, height: geometry.size.width-50)
									.clipShape(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15)))
									.shadow(color: .black, radius: 20)
								Spacer()
							}
						}
						.frame(height: geometry.size.height * (1 - (Self.barHeightFactor * 2)))
						.background(Rectangle().foregroundStyle(.black).opacity(0.85))
					}
					
				}
				.background(.black)
		}
		.onReceive(viewModel.transferableDone, perform: { result in
			if result == true {
				showPickerSelectedPhoto = true
				model.thumbnailImage = nil
				model.camera.isPreviewPaused = true
			}
		})
		.task {
			await model.camera.start()
			//await model.loadPhotos()
			//await model.loadThumbnail()
		}
		.navigationTitle("Camera")
		.navigationBarTitleDisplayMode(.inline)
		.navigationBarHidden(true)
		.ignoresSafeArea()
		.statusBar(hidden: true)
		
	}
	
	private func buttonsView() -> some View {
		VStack {
			HStack {
				
				Spacer()
				
				/*NavigationLink {
				 PhotoCollectionView(photoCollection: model.photoCollection)
				 .onAppear {
				 model.camera.isPreviewPaused = true
				 }
				 .onDisappear {
				 model.camera.isPreviewPaused = false
				 }
				 } label: {
				 Label {
				 Text("Gallery")
				 } icon: {
				 ThumbnailView(image: model.thumbnailImage)
				 }
				 }*/
				PhotosPicker(selection: $viewModel.imageSelection,
										 matching: .images,
										 photoLibrary: .shared()) {
					Label {
						Text("Photo Library")
					} icon: {
						Image(systemName: "photo.circle")
					}
					.foregroundStyle(.white)
					.font(.system(size: 36, weight: .bold))
					.labelStyle(.iconOnly)
				}
				Spacer()
				if showPickerSelectedPhoto == false {
					if model.thumbnailImage == nil {
						Button {
							model.camera.takePhoto()
							model.camera.isPreviewPaused = true
						} label: {
							Label {
								Text("Take Photo")
							} icon: {
								ZStack {
									Circle()
										.strokeBorder(.white, lineWidth: 3)
										.frame(width: 62, height: 62)
									Circle()
										.fill(.white)
										.frame(width: 50, height: 50)
								}
							}.labelStyle(.iconOnly)
						}
						.buttonStyle(.plain)
						Spacer()
						Button {
							model.camera.switchCaptureDevice()
						} label: {
							Label("Switch Camera", systemImage: "arrow.triangle.2.circlepath")
								.font(.system(size: 36, weight: .bold))
								.foregroundColor(.white)
								.labelStyle(.iconOnly)
						}
					} else {
						Button(action: {
							showPickerSelectedPhoto = false
							model.thumbnailImage = nil
							model.camera.isPreviewPaused = false
						}, label: {
							Label(
								title: { Text("Retake").bold() },
								icon: { Image(systemName: "42.circle") }
							).foregroundStyle(.white)
								.labelStyle(.titleOnly)
						})
					}
				} else {
					Button(action: {
						showPickerSelectedPhoto = false
						model.thumbnailImage = nil
						model.camera.isPreviewPaused = false
					}, label: {
						Label {
							Text("Take a New Picture")
						} icon: {
							Image(systemName: "camera.circle")
						}
						.foregroundStyle(.white)
						.font(.system(size: 36, weight: .bold))
						.labelStyle(.iconOnly)
					})
					
					
				}
				
				
				Spacer()
				
			}
		}.padding()
	}
	
}
