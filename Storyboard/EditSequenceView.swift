//
//  EditSequenceView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/10/23.
//

import SwiftUI

struct EditSequenceView: View {
	@Environment(\.colorScheme) var colorScheme
	
	@Binding var showEditSequence:Bool
	@Binding var showStoryboard:Bool
	
	var body: some View {
		VStack {
			HStack {
				Label(
					title: { Text("Back to list") },
					icon: { Image(systemName: "chevron.backward") }
				)
				.font(.title)
				.labelStyle(.iconOnly)
				.onTapGesture {
					
				}
				Spacer()
				Text("Edit Sequence")
					.font(.title)
				Spacer()
			}
			.padding(15)
			
			PreviewStoryView(showSequenceActionView: $showEditSequence, showStoryboard: $showStoryboard)
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
