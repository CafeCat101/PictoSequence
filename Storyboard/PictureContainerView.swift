//
//  PictureContainerView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/11/4.
//

import SwiftUI

struct PictureContainerView: View {
	@Binding var wordCard:WordCard
	//let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
	
	var body: some View {
		if FileManager.default.fileExists(atPath: wordCard.pictureLocalPath) {
			let pictureURL = URL(string: wordCard.pictureLocalPath, relativeTo: FileManager.documentoryDirecotryURL)!
			Image(uiImage: UIImage(contentsOfFile: pictureURL.absoluteString)!)
		} else {
			AsyncImage(url: URL(string: wordCard.iconURL)) { phase in
				if let image = phase.image {
					image
						.resizable()
						.scaledToFit()
						.padding()
						.onAppear(perform: {
							print("[debug] APictureView, AsyncImage.onAppear, word \(wordCard.word)")
						})
				} else if phase.error != nil {
					Text("There was an error loading the image.")
				} else {
					ProgressView()
				}
			}
		}
	}
}

/*#Preview {
 PictureContainerView(wordCard: WordCard())
 }*/
