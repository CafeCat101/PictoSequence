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
	var showImages:[MyImage] = []
	let columns = [
					GridItem(.adaptive(minimum: 100, maximum: 140))
			]
	
	var body: some View {
		VStack {
			if showImages.count > 0 {
				LazyVGrid(columns: columns, spacing: 20) {
					ForEach(showImages) { imageItem in
						if imageItem.localPicturePath == card.pictureLocalPath {
							imageItem.image
								.resizable()
								.scaledToFill()
								.frame(minWidth: 100, maxWidth: 140, minHeight: 100, maxHeight: 140)
								.clipShape(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15)))
								.background {
									RoundedRectangle(cornerRadius: 15)
										.foregroundColor(Color("word_icon_bg"))
										.opacity(colorScheme == .dark ? 0.5 : 0.8)
										.shadow(color: .black, radius: 5)
								}
								.overlay(alignment: .topLeading, content: {
									Label("selected", systemImage: "checkmark.circle.fill")
										.labelStyle(.iconOnly)
										.foregroundColor(.green)
										.padding([.top,.leading], 5)
								})
						} else {
							imageItem.image
								.resizable()
								.scaledToFill()
								.frame(minWidth: 100, maxWidth: 140, minHeight: 100, maxHeight: 140)
								.clipShape(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15)))
								.background {
									RoundedRectangle(cornerRadius: 15)
										.foregroundColor(Color("word_icon_bg"))
										.opacity(colorScheme == .dark ? 0.5 : 0.8)
										.shadow(color: .black, radius: 5)
								}
								.onTapGesture(perform: {
									print("[debug] AllSavedPictureView, image.onTap \(imageItem.localPicturePath)")
								})
						}
						
					}
				}
			} else {
				Text("Your saved picture will be available after you have saved sentences.")
			}
		}
	}
}

#Preview {
	AllSavedPictureView()
}
