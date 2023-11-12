//
//  ShowStoryView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/9/27.
//

import SwiftUI

struct ShowStoryView: View {
	@EnvironmentObject var sequencer:Sequencer
	@Binding var showStoryboard:Bool
	
	@State private var sentence = ""
	@State private var pictureCards:[WordCard] = []
	
	var body: some View {
		VStack {
			HStack {
				Label(
					title: { Text("Back to List") },
					icon: { Image(systemName: "list.bullet.rectangle") }
				)
				.labelStyle(.iconOnly)
				.onTapGesture {
					showStoryboard = false
				}
				Spacer()
			}
			.padding([.trailing,.leading], 15)
			Spacer()
			StoryView()
			Spacer()
		}
		.background(
			LinearGradient(gradient: Gradient(colors: [Color("testColor"), Color("testColor3")]), startPoint: .top, endPoint: .bottom)
		)
		.onAppear(perform: {
			print("[debug] PreviewStoryView, onAppear, sequencer.theStoryByUser.sentence \(sequencer.theStoryByUser.sentence)")
			sentence = sequencer.theStoryByUser.sentence
			pictureCards = sequencer.theStoryByUser.visualizedSequence
		})
		//.background(Color("testColor"))
	}
}

#Preview {
	ShowStoryView(showStoryboard: .constant(true))
}
