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
			/*HStack {
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
			.padding([.trailing,.leading], 15)*/
			
			
			HStack {
				Button(action: {
					showStoryboard = false
				}, label: {
					Label(
						title: { Text("Back to the List") },
						icon: { Image(systemName: "chevron.backward") }
					)
				})
				Spacer()
				/*Button(action: {
					
				}, label: {
					Label("Edit", systemImage: "square.and.pencil.circle")
						.labelStyle(.iconOnly)
						.font(.system(size:32))
				})*/
			}
			.foregroundColor(Color("testColor2"))
			.padding([.leading,.top,.trailing], 15)
			.padding([.bottom], 5)
			
			
			Spacer()
			StoryView(storyViewMode: $storyViewMode)
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
		.ignoresSafeArea(edges: .bottom)
	}
}

#Preview {
	ShowStoryView(showStoryboard: .constant(true))
}
