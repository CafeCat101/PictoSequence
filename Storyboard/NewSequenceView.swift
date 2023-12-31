//
//  NewSequenceView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/9/29.
//

import SwiftUI
import CoreData

struct NewSequenceView: View {
	@EnvironmentObject var sequencer:Sequencer
	@Environment(\.colorScheme) var colorScheme
	@Environment(\.managedObjectContext) private var manageContext
	
	@State private var text = ""
	@State var previewSequence = false
	@State private var showProgressSpinner = false
	@State private var storyViewMode:StoryViewMode = .newSentence

	@Binding var showAddNewSequence:Bool
	@Binding var showStoryboard:Bool
	@Binding var tappedSentenceID:String
	
    var body: some View {
			
			VStack {
				HStack {
					if previewSequence {
						Button(action: {
							previewSequence = false
						}, label: {
							Label(
								title: { Text("Back to new sentence") },
								icon: { Image(systemName: "chevron.backward") }
							)
							.font(.title)
							.labelStyle(.iconOnly)
						})
					}
					Spacer()
					Button(action: {
						previewSequence = false
						showAddNewSequence = false
					}, label: {
						Label(
							title: { Text("Back to list") },
							icon: { Image(systemName: "xmark.circle") }
						)
						.font(.title)
						.labelStyle(.iconOnly)
					})
				}.padding([.top,.leading,.trailing], 15)
				
				HStack {
					Spacer()
					Text("New Sentence")
						.font(.title)
						.bold()
					Spacer()
				}
				/*.overlay(alignment: .top, content: {
				})
				.frame(height:46)*/
		
				if previewSequence == false {
					VStack {
						TextEditor(text: $text)
							.font(.title2)
							.padding(5)
							.scrollContentBackground(.hidden)
							.background(Color.brown.opacity(0.3))
							.frame(maxHeight: 205)
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
									ProgressView().padding([.trailing], 5)
									//SpinnerView(iconColor: .black, spinnerColor: .green, iconSystemImage: "stop.fill")
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
					PreviewStoryView(showSequenceActionView: $showAddNewSequence, showStoryboard: $showStoryboard, storyViewMode: $storyViewMode, tappedSentenceID: $tappedSentenceID)
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
			
			//for preview, replace icon with word's "picture" saved in CoreData if it exists
			for wordCardItem in sequencer.theStoryByUser.visualizedSequence {
				let fetchWords = NSFetchRequest<Words>(entityName: "Words")
				fetchWords.predicate = NSPredicate(format: "word = %@", wordCardItem.word)
				fetchWords.sortDescriptors = [NSSortDescriptor(keyPath: \Words.wordChanged, ascending: false)]
				//fetchWords.fetchLimit = 1
				print("[debug] NewSequenceView, generate(), look up word \(wordCardItem.word)")
				let lastWordUsed = try manageContext.fetch(fetchWords)
				print("[debug] NewSequenceView, generate(), lastWordUsed \(String(describing: lastWordUsed.first?.word))")
				if lastWordUsed.count > 0 {
					let fetchPictures = NSFetchRequest<Pictures>(entityName: "Pictures")
					fetchPictures.predicate = NSPredicate(format: "id = %@", lastWordUsed.first?.picID ?? "")
					let lastPictureUsed = try manageContext.fetch(fetchPictures)
					if lastPictureUsed.count > 0 {
						let findWordCards = sequencer.theStoryByUser.visualizedSequence.filter({$0.word == wordCardItem.word})
						if findWordCards.count > 0 {
							for wordCard in findWordCards {
								let findWordCardIndex = sequencer.theStoryByUser.visualizedSequence.firstIndex(where: {$0.id == wordCard.id}) ?? -1
								
								let thePictureIDString = lastPictureUsed.first?.id ?? ""
								sequencer.theStoryByUser.visualizedSequence[findWordCardIndex].pictureID = UUID(uuidString: thePictureIDString) ?? UUID()
								sequencer.theStoryByUser.visualizedSequence[findWordCardIndex].pictureLocalPath = lastPictureUsed.first?.pictureLocalPath ?? ""
								
								if lastPictureUsed.first?.type == PictureSource.icon.rawValue {
									sequencer.theStoryByUser.visualizedSequence[findWordCardIndex].pictureType = .icon
									sequencer.theStoryByUser.visualizedSequence[findWordCardIndex].iconURL = lastPictureUsed.first?.iconURL ?? ""
								} else if lastPictureUsed.first?.type == PictureSource.camera.rawValue {
									sequencer.theStoryByUser.visualizedSequence[findWordCardIndex].pictureType = .camera
								} else {
									sequencer.theStoryByUser.visualizedSequence[findWordCardIndex].pictureType = .photoPicker
								}
							}
						}
						
						
						/*let findWordIndex = sequencer.theStoryByUser.visualizedSequence.firstIndex(where: {$0.word == wordCardItem.word}) ?? -1
						if findWordIndex >= 0 {
							let thePictureIDString = lastPictureUsed.first?.id ?? ""
							sequencer.theStoryByUser.visualizedSequence[findWordIndex].pictureID = UUID(uuidString: thePictureIDString) ?? UUID()
							sequencer.theStoryByUser.visualizedSequence[findWordIndex].pictureLocalPath = lastPictureUsed.first?.pictureLocalPath ?? ""
							
							if lastPictureUsed.first?.type == PictureSource.icon.rawValue {
								sequencer.theStoryByUser.visualizedSequence[findWordIndex].pictureType = .icon
								sequencer.theStoryByUser.visualizedSequence[findWordIndex].iconURL = lastPictureUsed.first?.iconURL ?? ""
							} else if lastPictureUsed.first?.type == PictureSource.camera.rawValue {
								sequencer.theStoryByUser.visualizedSequence[findWordIndex].pictureType = .camera
							} else {
								sequencer.theStoryByUser.visualizedSequence[findWordIndex].pictureType = .photoPicker
							}
						}*/
					}
				}
			}
			
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
