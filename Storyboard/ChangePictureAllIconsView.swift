//
//  ChangePictureAllIconsView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/11/21.
//

import SwiftUI

struct ChangePictureAllIconsView: View {
	@Environment(\.colorScheme) var colorScheme
	
	var card:WordCard = WordCard()
	@ObservedObject var iconOptionsModel:PictureOptionsByWord
	
	let columns = [
		GridItem(.adaptive(minimum: 100, maximum: 140))
	]
	
	var body: some View {
		VStack {
			if iconOptionsModel.availablePictures.count > 0 {
				Text("\(iconOptionsModel.availablePictures.count) icons for \(card.word)")
			} else {
				Text("Your saved picture will be available after you have saved sentences.")
			}
		}
		.onAppear(perform: {
		})
	}
}

/*
 #Preview {
 ChangePictureAllIconsView(iconOptionsModel: PictureOptionsByWord())
 }
 */
