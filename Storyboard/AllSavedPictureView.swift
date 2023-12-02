//
//  ChangePictureSavedPictureView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/11/21.
//

import SwiftUI
import CoreData

struct AllSavedPictureView: View {
	@Environment(\.colorScheme) var colorScheme
	
	var card:WordCard = WordCard()
	@ObservedObject var savedPictureModel:PictureOptionsByWord
	@Binding var showChangePictureView:Bool
	
	let columns = [
		GridItem(.adaptive(minimum: 100, maximum: 140))
	]
	
	@State private var tapThis:UUID = UUID()
	@State private var imageSize:CGFloat = 110
	
	var body: some View {
		VStack {
			if savedPictureModel.availablePictures.count > 0 {
				LazyVGrid(columns: columns, spacing: 20) {
					ForEach(savedPictureModel.availablePictures) { imageItem in
						if imageItem.localPicturePath == card.pictureLocalPath || imageItem.id == tapThis {
							displayImage(savedImage: imageItem.image!)
								.overlay(alignment: .topLeading, content: {
									Label("selected", systemImage: "checkmark.circle.fill")
										.labelStyle(.iconOnly)
										.foregroundColor(.green)
										.padding([.top,.leading], 5)
								})
								.onAppear(perform: {
									print("[debug] AllSavedPictureView, selected:iconOption-localPath \(imageItem.localPicturePath) & card.localPath \(card.pictureLocalPath)")
								})
						} else {
							displayImage(savedImage: imageItem.image!)
								.onTapGesture(perform: {
									tapThis = imageItem.id
									savedPictureModel.pictureSelected.send(imageItem)
									DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
										showChangePictureView = false
									}
									print("[debug] AllSavedPictureView, image.onTap \(imageItem.localPicturePath)")
								})
								.onAppear(perform: {
									print("[debug] AllSavedPictureView, option:iconOption-localPath \(imageItem.localPicturePath) & card.localPath \(card.pictureLocalPath)")
								})
						}
						
					}
				}
			} else {
				Text("Your saved picture will be available after you have saved sentences.")
			}
		}
	}
	
	@ViewBuilder
	private func displayImage(savedImage: UIImage) -> some View {
		Image(uiImage: savedImage)
			.resizable()
			.scaledToFill()
			.frame(width:imageSize, height:imageSize)
			//.frame(minWidth: 100, maxWidth: 140, minHeight: 100, maxHeight: 140)
			.clipShape(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15)))
			.background {
				RoundedRectangle(cornerRadius: 15)
					.foregroundColor(Color("word_icon_bg"))
					.opacity(colorScheme == .dark ? 0.5 : 0.8)
					.shadow(color: .black, radius: 5)
			}
	}
}

/*#Preview {
	AllSavedPictureView()
}*/
