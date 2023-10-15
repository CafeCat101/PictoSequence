//
//  ThumbnailView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/10/15.
//

import SwiftUI

struct ThumbnailView: View {
		var image: Image?
		
		var body: some View {
				ZStack {
						Color.white
						if let image = image {
								image
										.resizable()
										.scaledToFill()
						}
				}
				.frame(width: 41, height: 41)
				.cornerRadius(11)
		}
}

struct ThumbnailView_Previews: PreviewProvider {
		static let previewImage = Image(systemName: "photo.fill")
		static var previews: some View {
				ThumbnailView(image: previewImage)
		}
}
