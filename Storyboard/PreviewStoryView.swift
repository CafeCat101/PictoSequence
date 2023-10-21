//
//  PreviewStoryView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/10/21.
//

import SwiftUI

struct PreviewStoryView: View {
	@EnvironmentObject var sequencer:Sequencer
	@Environment(\.colorScheme) var colorScheme
	
	var previewSentence:String = ""
	@Binding var showAddNewSequence:Bool
	@Binding var showStoryboard:Bool

	var body: some View {
		VStack {
			Text(previewSentence)
				.font(.title2)
				.bold()
			StoryView()
			.background {
				RoundedRectangle(cornerRadius: 10)
					.foregroundColor(.brown)
					.opacity(0.3)
			}
			.padding(15)
			
			HStack {
				Spacer()
				Button(action: {
					showAddNewSequence = false
				}, label: {
					Label(
						title: { Text("Save It").bold() },
						icon: { Image(systemName: "checkmark.circle.fill") }
					)
				})
				.padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
				.background {
					RoundedRectangle(cornerRadius: 10)
						.foregroundColor(.green)
						.opacity(0.5)
				}
				Button(action: {
					showAddNewSequence = false
					showStoryboard = true
				}, label: {
					Label(
						title: { Text("Show Now").bold() },
						icon: { Image(systemName: "eyeglasses") }
					)
				})
				.padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
				.background {
					RoundedRectangle(cornerRadius: 10)
						.foregroundColor(.blue)
						.opacity(0.5)
				}
				Spacer()
			}
		}
	}
}

#Preview {
	PreviewStoryView(showAddNewSequence: .constant(false), showStoryboard: .constant(false))
}
