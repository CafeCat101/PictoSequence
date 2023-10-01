//
//  NewSequenceView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/9/29.
//

import SwiftUI

struct NewSequenceView: View {
	@State private var text = ""
	@Binding var showAddNewSequence:Bool
	@State private var previewSequence = false
	@Environment(\.colorScheme) var colorScheme
	
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
									title: { Text("Clear") },
									icon: { Image(systemName: "eraser.fill") }
								)
							})
							.padding(EdgeInsets(top: 8, leading: 15, bottom: 8, trailing: 15))
							.background {
								RoundedRectangle(cornerRadius: 26)
									.foregroundColor(.gray)
									.opacity(0.5)
							}
						}
						
						Button(action: {
							previewSequence = true
						}, label: {
							Label(
								title: { Text("Generate Sequence") },
								icon: { Image(systemName: "bolt.circle.fill") }
							)
						})
						.disabled(text.isEmpty ? true : false)
						.padding(EdgeInsets(top: 8, leading: 15, bottom: 8, trailing: 15))
						.background {
							RoundedRectangle(cornerRadius: 26)
								.foregroundColor(.brown)
								.opacity(0.5)
						}
					}
				} else {
					Text(text)
						.font(.title2)
						.bold()
					
					VStack {
						HStack {
							Spacer()
							Text("preview the story")
							Spacer()
						}
						Spacer()
					}
					.background {
						RoundedRectangle(cornerRadius: 10)
							.foregroundColor(.brown)
							.opacity(0.3)
					}
					.padding(15)
					
					HStack {
						Spacer()
						Button(action: {
							
						}, label: {
							Label(
								title: { Text("Save It") },
								icon: { Image(systemName: "checkmark.circle.fill") }
							)
						})
						.padding(EdgeInsets(top: 8, leading: 15, bottom: 8, trailing: 15))
						.background {
							RoundedRectangle(cornerRadius: 26)
								.foregroundColor(.green)
								.opacity(0.5)
						}
						Button(action: {
							
						}, label: {
							Label(
								title: { Text("Show Now") },
								icon: { Image(systemName: "eyeglasses") }
							)
						})
						.padding(EdgeInsets(top: 8, leading: 15, bottom: 8, trailing: 15))
						.background {
							RoundedRectangle(cornerRadius: 26)
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
			.background(Image(colorScheme == .light ? "old_paper_bg2" : "black_canvas_bg6").resizable()
				.aspectRatio(contentMode: .fill)
			 .edgesIgnoringSafeArea(.all))
    }
}

#Preview {
	NewSequenceView(showAddNewSequence: .constant(true))
}
