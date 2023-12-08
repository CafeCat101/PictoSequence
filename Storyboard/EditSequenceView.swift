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
	
	var body: some View {
		VStack {
			HStack {
				Spacer()
				Text("Edit Sentence")
					.font(.title)
				Spacer()
			}
			.overlay(alignment: .topLeading, content: {
				Button(action: {
					showEditSequence = false
				}, label: {
					Label(
						title: { Text("Back to list") },
						icon: { Image(systemName: "chevron.backward") }
					)
					.font(.title)
					.labelStyle(.iconOnly)
				})
				.frame(width:46, height: 46)
			})
			.frame(height:46)
			.padding(15)
			
			PreviewStoryView(showSequenceActionView: $showEditSequence, showStoryboard: $showStoryboard, storyViewMode: $storyViewMode)
		}
		.foregroundColor(Color("testColor2"))
		.background(
			Image(colorScheme == .light ? "vellum_sketchbook_paper" : "balck_canvas_bg4").resizable()
				.aspectRatio(contentMode: .fill)
				.edgesIgnoringSafeArea(.all))
	}
}

#Preview {
	EditSequenceView(showEditSequence: .constant(false), showStoryboard: .constant(false))
}
