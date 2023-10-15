//
//  ViewFinderView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/10/15.
//

import SwiftUI

struct ViewFinderView: View {
		@Binding var image: Image?
		
		var body: some View {
				GeometryReader { geometry in
						if let image = image {
								image
										.resizable()
										.scaledToFill()
										.frame(width: geometry.size.width, height: geometry.size.height)
						}
				}
		}
}

