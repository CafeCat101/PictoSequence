//
//  EditSequenceView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/10/23.
//

import SwiftUI

struct EditSequenceView: View {
	@Environment(\.colorScheme) var colorScheme
	
	@State private var storyViewMode:StoryViewMode = .editSentence
	
	@Binding var showEditSequence:Bool
	@Binding var showStoryboard:Bool
	@Binding var tappedSentenceID:String
	
	var body: some View {
		VStack {
			HStack {
				Spacer()
				Button(action: {
					showEditSequence = false
				}, label: {
					Label(
						title: { Text("Back to list") },
						icon: { Image(systemName: "xmark.circle") }
					)
					.font(.title)
					.labelStyle(.iconOnly)
				})
				//.frame(width:46, height: 46)
			}.padding([.leading,.trailing,.top], 15)
			
			HStack {
				Spacer()
				Text("Edit Sentence")
					.font(.title)
					.bold()
				Spacer()
			}.padding([.bottom], 15)
			
			PreviewStoryView(showSequenceActionView: $showEditSequence, showStoryboard: $showStoryboard, storyViewMode: $storyViewMode, tappedSentenceID: $tappedSentenceID)
		}
		.foregroundColor(Color("testColor2"))
		.background(
			Image(colorScheme == .light ? "vellum_sketchbook_paper" : "balck_canvas_bg4").resizable()
				.aspectRatio(contentMode: .fill)
				.edgesIgnoringSafeArea(.all))
	}
}
/*
#Preview {
	EditSequenceView(showEditSequence: .constant(false), showStoryboard: .constant(false))
}*/
