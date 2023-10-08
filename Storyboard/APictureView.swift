//
//  APictureView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/10/8.
//

import SwiftUI

struct APictureView: View {
	var word:String = "pic"
	var urlStr:String = "https://static.thenounproject.com/png/5222984-200.png"
	var picWidth:CGFloat = 200
	var picHeight:CGFloat = 200
	@State private var showPic = true
	
	var body: some View {
		AsyncImage(url: URL(string: urlStr)) { phase in
			if let image = phase.image {
				image
					.resizable()
					.scaledToFit()
					.padding()
			} else if phase.error != nil {
				Text("There was an error loading the image.")
			} else {
				ProgressView()
			}
		}
		.frame(width: picWidth, height: picHeight)
		.onTapGesture {
			showPic = false
		}
		.opacity(showPic ? 1 : 0)
		.disabled(showPic ? false : true)
		.overlay(content: {
			if showPic == false {
				VStack(spacing:0) {
					Spacer()
					HStack(spacing:0){
						Spacer()
						Text(word)
							.font(.headline)
							.padding()
							.foregroundColor(.white)
						Spacer()
					}
					Spacer()
				}
				.frame(minWidth: picWidth, minHeight: picHeight)
				.background {
					RoundedRectangle(cornerRadius: 10)
						.foregroundColor(.black)
				}
				.onTapGesture {
					showPic = true
				}
				.opacity(showPic ? 0 : 1)
				.disabled(showPic ? true : false)
			}
		})
		
		/*if showPic {
		 AsyncImage(url: URL(string: urlStr)) { phase in
		 if let image = phase.image {
		 image
		 .resizable()
		 .scaledToFit()
		 .padding()
		 } else if phase.error != nil {
		 Text("There was an error loading the image.")
		 } else {
		 ProgressView()
		 }
		 }
		 .frame(width: picWidth, height: picHeight)
		 .onTapGesture {
		 showPic = false
		 }
		 } else {
		 Text(word)
		 .font(.headline)
		 .padding()
		 .frame(minWidth: picWidth, minHeight: picHeight)
		 .onTapGesture {
		 showPic = true
		 }
		 }*/
		
	}
}

#Preview {
	APictureView()
}
