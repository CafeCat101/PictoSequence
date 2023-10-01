//
//  ShowStoryView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/9/27.
//

import SwiftUI

struct ShowStoryView: View {
	@Binding var showStoryboard:Bool
	
	var body: some View {
		VStack {
			HStack {
				Label(
					title: { Text("Back to List") },
					icon: { Image(systemName: "arrowshape.backward.fill") }
				)
				.labelStyle(.iconOnly)
				.onTapGesture {
					showStoryboard = false
				}
				Spacer()
			}
			.padding([.trailing,.leading], 15)
			Spacer()
			HStack {
				Spacer()
				Text("Show story pictures")
				Spacer()
			}
			
			Spacer()
		}
		.background(
			LinearGradient(gradient: Gradient(colors: [Color("testColor"), Color("testColor3")]), startPoint: .top, endPoint: .bottom)
		)
		//.background(Color("testColor"))
	}
}

#Preview {
	ShowStoryView(showStoryboard: .constant(true))
}
