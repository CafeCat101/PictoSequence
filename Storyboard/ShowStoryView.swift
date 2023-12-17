//
//  ShowStoryView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/9/27.
//

import SwiftUI

struct ShowStoryView: View {
	@EnvironmentObject var sequencer:Sequencer
	@Environment(\.colorScheme) var colorScheme
	
	@Binding var showStoryboard:Bool
	
	@State private var sentence = ""
	@State private var pictureCards:[WordCard] = []
	@State private var storyViewMode:StoryViewMode = .showSentence
	
	var body: some View {
		VStack {
			Spacer()
			StoryView(storyViewMode: $storyViewMode)
				.overlay(alignment: .topLeading, content: {
					Button(action: {
						showStoryboard = false
					}, label: {
						Label(
							title: { Text("Back to the List") },
							icon: { Image(systemName: "chevron.backward") }
						)
						.font(.title)
						.labelStyle(.iconOnly)
					})
					.foregroundColor(Color("testColor2"))
					.frame(width: 46, height: 46)
					.padding([.top], 30)
				})
			Spacer()
		}
		/*.background(
			LinearGradient(gradient: Gradient(colors: [Color("testColor"), Color("testColor3")]), startPoint: .top, endPoint: .bottom)
		)*/
		.onAppear(perform: {
			print("[debug] PreviewStoryView, onAppear, sequencer.theStoryByUser.sentence \(sequencer.theStoryByUser.sentence)")
			sentence = sequencer.theStoryByUser.sentence
			pictureCards = sequencer.theStoryByUser.visualizedSequence
		})
		.background(
			Image(colorScheme == .light ? "vellum_sketchbook_paper" : "balck_canvas_bg4").resizable()
				.aspectRatio(contentMode: .fill)
				.edgesIgnoringSafeArea(.all))
		.ignoresSafeArea(edges: [.bottom,.top])
	}
}

#Preview {
	ShowStoryView(showStoryboard: .constant(true))
}
