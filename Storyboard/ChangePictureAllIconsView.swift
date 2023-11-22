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
						imageItem.image
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
			showImages.append(MyImage(image: Image(systemName:"square.and.arrow.up")))
			showImages.append(MyImage(image: Image(systemName:"square.and.arrow.up.trianglebadge.exclamationmark")))
			showImages.append(MyImage(image: Image(systemName:"square.and.arrow.up.on.square.fill")))
			showImages.append(MyImage(image: Image(systemName:"rectangle.portrait.and.arrow.right.fill")))
			showImages.append(MyImage(image: Image(systemName: "eraser.line.dashed")))
			showImages.append(MyImage(image: Image(systemName:"square.and.arrow.up")))
			showImages.append(MyImage(image: Image(systemName:"square.and.arrow.up.trianglebadge.exclamationmark")))
			showImages.append(MyImage(image: Image(systemName:"square.and.arrow.up.on.square.fill")))
			showImages.append(MyImage(image: Image(systemName:"rectangle.portrait.and.arrow.right.fill")))
			showImages.append(MyImage(image: Image(systemName: "eraser.line.dashed")))
			showImages.append(MyImage(image: Image(systemName:"square.and.arrow.up")))
			showImages.append(MyImage(image: Image(systemName:"square.and.arrow.up.trianglebadge.exclamationmark")))
			showImages.append(MyImage(image: Image(systemName:"square.and.arrow.up.on.square.fill")))
			showImages.append(MyImage(image: Image(systemName:"rectangle.portrait.and.arrow.right.fill")))
			showImages.append(MyImage(image: Image(systemName: "eraser.line.dashed")))
		})
	}
}

#Preview {
	ChangePictureAllIconsView()
}
