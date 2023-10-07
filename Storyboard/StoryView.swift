//
//  PreviewStoryView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/10/6.
//

import SwiftUI

struct StoryView: View {
	@EnvironmentObject var sequencer:Sequencer
	let columns = [
		GridItem(.flexible()),
		//GridItem(.flexible()),
		//GridItem(.flexible())
	]
	
	var body: some View {
		VStack {
			/*HStack {
			 Spacer()
			 Text("preview your story")
			 Spacer()
			 }*/
			if sequencer.currentStory.sequence.count > 0 {
				LazyVGrid(columns: columns) {
					ForEach(sequencer.currentStory.sequence , id: \.self) { item in
						VStack {
							Text(item.word[0])
								.font(.headline)
								.padding()
						}
						.background {
							RoundedRectangle(cornerRadius: 10)
								.foregroundColor(.green)
								.opacity(0.3)
						}
						.padding([.bottom,.trailing],5)
						/*VStack {
						 if index % 2 == 0 {
						 Text("story card \(index + 1)")
						 .font(.headline)
						 .padding()
						 .background(Color.green)
						 .cornerRadius(10)
						 } else {
						 EmptyView()
						 }
						 }.padding([.bottom,.trailing],5)*/
					}
				}
				.padding()
			}
			
			
			Spacer()
		}
	}
}

#Preview {
	StoryView()
}
