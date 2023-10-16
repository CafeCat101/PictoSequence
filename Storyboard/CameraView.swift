//
//  CameraView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/10/15.
//

import SwiftUI

struct CameraView: View {
		@StateObject private var model = DataModel()
 
		private static let barHeightFactor = 0.15
	@Binding var showCaptureView:Bool
		
		
		var body: some View {
				
				NavigationStack {
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
														).labelStyle(.titleOnly).bold()
													})
													Spacer()
													Button(action: {
														showCaptureView = false
													}, label: {
														Label(
															title: { Text("Use") },
															icon: { Image(systemName: "checkmark") }
														).labelStyle(.titleOnly).bold()
													}).disabled(true)
												}
												.padding([.leading,.trailing], 15)
												Spacer()
											}
											.frame(height: geometry.size.height * Self.barHeightFactor)
											.background(Rectangle().foregroundColor(.black).opacity(0.75))
											
										}
										.overlay(alignment: .bottom) {
												buttonsView()
														.frame(height: geometry.size.height * Self.barHeightFactor)
														.background(.black.opacity(0.75))
										}
										.overlay(alignment: .center)  {
												Color.clear
														.frame(height: geometry.size.height * (1 - (Self.barHeightFactor * 2)))
														.accessibilityElement()
														.accessibilityLabel("View Finder")
														.accessibilityAddTraits([.isImage])
										}
										.background(.black)
						}
						.task {
								await model.camera.start()
								await model.loadPhotos()
								await model.loadThumbnail()
						}
						.navigationTitle("Camera")
						.navigationBarTitleDisplayMode(.inline)
						.navigationBarHidden(true)
						.ignoresSafeArea()
						.statusBar(hidden: true)
				}
		}
		
		private func buttonsView() -> some View {
				HStack(spacing: 60) {
						
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
					
					Button(action: {
						
					}, label: {
						Label {
								Text("Photo Library")
						} icon: {
								Image(systemName: "photo")
						}.font(.system(size: 36, weight: .bold))
					})
						
						
						
						Button {
								model.camera.takePhoto()
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
								}
						}
						
						Button {
								model.camera.switchCaptureDevice()
						} label: {
								Label("Switch Camera", systemImage: "arrow.triangle.2.circlepath")
										.font(.system(size: 36, weight: .bold))
										.foregroundColor(.white)
						}
						
						Spacer()
				
				}
				.buttonStyle(.plain)
				.labelStyle(.iconOnly)
				.padding()
		}
		
}
