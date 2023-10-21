//
//  NewSequenceView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/9/29.
//

import SwiftUI

struct NewSequenceView: View {
	@EnvironmentObject var sequencer:Sequencer
	@State private var text = ""
	@Binding var showAddNewSequence:Bool
	@State private var previewSequence = false
	@Environment(\.colorScheme) var colorScheme
	@State private var showProgressSpinner = false
	@Binding var showStoryboard:Bool
	
    var body: some View {
			
			VStack {
				HStack {
					if previewSequence {
						Label(
							title: { Text("Back to List") },
							icon: { Image(systemName: "arrowshape.backward.fill") }
						)
						.labelStyle(.iconOnly)
						.font(.title)
						.onTapGesture {
							previewSequence = false
						}
					}
					Text("New Sequence")
						.font(.title)
					Spacer()
					Label(
						title: { Text("Close") },
						icon: { Image(systemName: "xmark.circle.fill") }
					)
					.font(.title)
					.labelStyle(.iconOnly)
					.onTapGesture {
						showAddNewSequence = false
					}
				}
				.padding(15)
		
				if previewSequence == false {
					VStack {
						TextEditor(text: $text)
							.font(.title2)
						//.clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
							.padding(5)
							.scrollContentBackground(.hidden)
							.background(Color.brown.opacity(0.3))
							.frame(maxHeight: 105)
							.cornerRadius(10)
						
					}
					.padding([.leading,.trailing], 15)
					.padding([.bottom],10)
					
					HStack {
						if text.isEmpty == false {
							Button(action: {
								text = ""
							}, label: {
								Label(
									title: { Text("Clear").bold() },
									icon: { Image(systemName: "eraser.fill") }
								)
							})
							.padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
							.background {
								RoundedRectangle(cornerRadius: 10)
									.foregroundColor(.gray)
									.opacity(0.5)
							}
						}
						
						Button(action: {
							Task {
								await generate()
							}
						}, label: {
							HStack {
								if showProgressSpinner == false {
									Label(
										title: { Text("Generate Sequence").bold() },
										icon: { Image(systemName: "bolt.circle.fill") }
									).labelStyle(.iconOnly)
								} else {
									SpinnerView(iconColor: .black, spinnerColor: .green, iconSystemImage: "stop.fill")
								}
								Text("Generate Sequence").bold()
							}
							
						})
						.disabled(text.isEmpty ? true : false)
						.padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
						.background {
							RoundedRectangle(cornerRadius: 10)
								.foregroundColor(.brown)
								.opacity(0.5)
						}
					}
				} else {
					Text(text)
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
				
				Spacer()
			}
			.onAppear(perform: {
				UITextView.appearance().backgroundColor = .clear
			})
			.foregroundColor(Color("testColor2"))
			.background(Image(colorScheme == .light ? "vellum_sketchbook_paper" : "balck_canvas_bg4").resizable()
				.aspectRatio(contentMode: .fill)
			 .edgesIgnoringSafeArea(.all))
    }
	
	private func generate() async {
		showProgressSpinner = true
		do {
			try await sequencer.currentStory = sequencer.generateNewSequence(sentence:text) ?? Story()
			showProgressSpinner = false
			if sequencer.currentStory.sequence.count > 0 {
				previewSequence = true
			}
		} catch {
			print("[debug] NewSequenceView, failed to generate new sequence")
			showProgressSpinner = false
		}
	}
}

#Preview {
	NewSequenceView(showAddNewSequence: .constant(true), showStoryboard: .constant(false))
}
