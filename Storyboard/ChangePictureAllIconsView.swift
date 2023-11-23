//
//  ChangePictureAllIconsView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/11/21.
//

import SwiftUI

struct ChangePictureAllIconsView: View {
	@State var word:String = ""
	
	@State private var showImages:[MyImage] = []
	let columns = [
					GridItem(.adaptive(minimum: 70, maximum: 120))
			]
	
	var body: some View {
		VStack {
			if showImages.count > 0 {
				LazyVGrid(columns: columns, spacing: 20) {
					ForEach(showImages) { imageItem in
						Image(uiImage: imageItem.image!)
							.resizable()
							.scaledToFill()
							.padding(15)
					}
				}
			} else {
				Text("Your saved picture will be available after you have saved sentences.")
			}
		}
		.onAppear(perform: {
		})
	}
}

#Preview {
	ChangePictureAllIconsView()
}
