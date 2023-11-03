//
//  NewSequenceView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/9/29.
//

import SwiftUI

struct NewSequenceView: View {
	@EnvironmentObject var sequencer:Sequencer
	@Environment(\.colorScheme) var colorScheme
	
	@State private var text = ""
	@State var previewSequence = false
	@State private var showProgressSpinner = false

	@Binding var showAddNewSequence:Bool
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
						if previewSequence == false {
							showAddNewSequence = false
						} else {
							previewSequence = false
						}
						
					}
					Spacer()
					Text("New Sequence")
						.font(.title)
					Spacer()
					
					
					
				}
				.padding(15)
		
				if previewSequence == false {
					VStack {
						TextEditor(text: $text)
							.font(.title2)
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
					PreviewStoryView(showSequenceActionView: $showAddNewSequence, showStoryboard: $showStoryboard)
				}
				
				Spacer()
			}
			.onAppear(perform: {
				UITextView.appearance().backgroundColor = .clear
			})
			.foregroundColor(Color("testColor2"))
			.background(
				Image(colorScheme == .light ? "vellum_sketchbook_paper" : "balck_canvas_bg4").resizable()
					.aspectRatio(contentMode: .fill)
					.edgesIgnoringSafeArea(.all))
    }
	
	private func generate() async {
		showProgressSpinner = true
		do {
			try await sequencer.theStoryByUser = sequencer.generateNewSequence(sentence:text) ?? StoryByUser()
			showProgressSpinner = false
			if sequencer.theStoryByUser.visualizedSequence.count > 0 {
				previewSequence = true
			}
		} catch {
			print("[debug] NewSequenceView, failed to generate new sequence")
			showProgressSpinner = false
		}
	}
}
/*
 #Preview {
 NewSequenceView(showAddNewSequence: .constant(true), path: NavigationPath())
 }
 */
