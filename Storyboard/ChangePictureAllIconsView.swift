//
//  ChangePictureAllIconsView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/11/21.
//

import SwiftUI
import CoreData

struct ChangePictureAllIconsView: View {
	@Environment(\.colorScheme) var colorScheme
	
	var card:WordCard = WordCard()
	@ObservedObject var iconOptionsModel:PictureOptionsByWord
	@Binding var showChangePictureView:Bool
	
	let columns = [
		GridItem(.adaptive(minimum: 100, maximum: 140))
	]
	
	@State private var tapThis:UUID = UUID()
	@State private var imageSize:CGFloat = 110
	
	var body: some View {
		VStack {
				LazyVGrid(columns: columns, spacing: 20) {
					ForEach(iconOptionsModel.availablePictures) { imageItem in

							if imageItem.localPicturePath == card.pictureLocalPath || imageItem.id == tapThis {
								displayImage(imageItem: imageItem)
									.overlay(alignment: .topLeading, content: {
										Label("selected", systemImage: "checkmark.circle.fill")
											.labelStyle(.iconOnly)
											.foregroundColor(.green)
											.padding([.top,.leading], 5)
									})
							} else {
								displayImage(imageItem: imageItem)
									.onTapGesture(perform: {
										tapThis = imageItem.id
										iconOptionsModel.pictureSelected.send(imageItem)
										DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
											showChangePictureView = false
										}
										print("[debug] AllSavedPictureView, image.onTap \(imageItem.localPicturePath)")
									})
							}
						
						
						
					}
				}
		}
	}
	
	@ViewBuilder
	private func displayImage(imageItem: MyImage) -> some View {
		if pictureExists(localPath: imageItem.localPicturePath) {
			Image(uiImage: UIImage(contentsOfFile: FileManager.documentoryDirecotryURL.appending(component: imageItem.localPicturePath).path())!)
				.resizable()
				.scaledToFit()
				.frame(width: imageSize, height: imageSize)
				//.frame(minWidth: 100, maxWidth: 140, minHeight: 100, maxHeight: 140)
				.clipShape(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15)))
				.background {
					RoundedRectangle(cornerRadius: 15)
						.foregroundColor(Color("word_icon_bg"))
						.opacity(colorScheme == .dark ? 0.5 : 0.8)
						.shadow(color: .black, radius: 5)
				}
		} else {
			AsyncImage(url: URL(string: imageItem.iconURL)) { phase in
				if let image = phase.image {
					image
						.resizable()
						.scaledToFit()
						.padding()
						.frame(width: imageSize, height: imageSize)
						//.frame(minWidth: 100, maxWidth: 140, minHeight: 100, maxHeight: 140)
						.clipShape(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15)))
						.background {
							RoundedRectangle(cornerRadius: 15)
								.foregroundColor(Color("word_icon_bg"))
								.opacity(colorScheme == .dark ? 0.5 : 0.8)
								.shadow(color: .black, radius: 5)
						}
						.onAppear(perform: {
							print("[debug] APictureCardView, displayImageFromFile, AsyncImage.onAppear(\(imageSize)), word \(card.word) \(card.pictureLocalPath)")
						})
				} else if phase.error != nil {
					/*Text("There was an error loading the image.")
						.onAppear(perform: {
							print("[debug] changePictureIcon, display image error(\(String(describing: phase.error)) \(imageItem.iconURL)")
						})*/
					AsyncImage(url: URL(string: imageItem.iconURL)) { phase in
									if let image = phase.image {
										image
											.resizable()
											.scaledToFit()
											.padding()
											.frame(width: imageSize, height: imageSize)
											//.frame(minWidth: 100, maxWidth: 140, minHeight: 100, maxHeight: 140)
											.clipShape(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15)))
											.background {
												RoundedRectangle(cornerRadius: 15)
													.foregroundColor(Color("word_icon_bg"))
													.opacity(colorScheme == .dark ? 0.5 : 0.8)
													.shadow(color: .black, radius: 5)
											}
									} else{
										ProgressView()
									}
								}
				} else {
					ProgressView()
						.onAppear(perform: {
							print("[debug] APictureCardView, displayImageFromFile, AsyncImage-ProgressView() word \(card.word) \(card.pictureLocalPath)")
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

/*
 #Preview {
 ChangePictureAllIconsView(iconOptionsModel: PictureOptionsByWord())
 }
 */
