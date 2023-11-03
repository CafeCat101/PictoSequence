//
//  PreviewStoryView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/10/21.
//

import SwiftUI
import CoreData

struct PreviewStoryView: View {
	@EnvironmentObject var sequencer:Sequencer
	@Environment(\.colorScheme) var colorScheme
	@Environment(\.managedObjectContext) private var manageContext
	let fetchRequest = NSFetchRequest<Sentences>(entityName: "Sentences")
	
	//var previewSentence:String = ""
	@Binding var showSequenceActionView:Bool
	@Binding var showStoryboard:Bool
	
	@State private var showSaveErrorAlert = false
	@State private var saveError = ""

	var body: some View {
		VStack {
			Text(sequencer.theStoryByUser.sentence)
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
					saveSequence(showStoryNow: false)
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
					saveSequence(showStoryNow: true)
				}, label: {
					Label(
						title: { Text("Save and Show").bold() },
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
			}.alert("\(saveError)", isPresented: $showSaveErrorAlert) {
				Button("OK", role: .cancel) { }
			}
		}
		.onAppear(perform: {
			fetchRequest.predicate = NSPredicate(format: "user_question = %@", sequencer.theStoryByAI.sentence)
		})
	}
	
	private func saveSequence(showStoryNow: Bool) {
		do {
			let existedSentences = try manageContext.fetch(fetchRequest)
			if existedSentences.isEmpty {
				let newID = UUID()
				let newItem = Sentences(context: manageContext)
				newItem.user_question = sequencer.theStoryByUser.sentence
				newItem.id = newID
				//newItem.user_question = sequencer.theStoryByAI.sentence
				//let seguenceJson = try JSONEncoder().encode(sequencer.theStoryByAI.visualizedSequence)
				//newItem.result = String(data: seguenceJson, encoding: .utf8)!
				newItem.change_date = Date()
				try manageContext.save()
				
				var wordOrderCount = 0
				for wordCard in sequencer.theStoryByUser.visualizedSequence {
					wordOrderCount = wordOrderCount + 1
					let fetchWords = NSFetchRequest<Words>(entityName: "Words")
					fetchWords.predicate = NSPredicate(format: "word = %@", wordCard.word)
					fetchWords.sortDescriptors = [NSSortDescriptor(keyPath: \Words.wordChanged, ascending: false)]
					fetchWords.fetchLimit = 1
					print("[debug] PreviewStoryView, before viewContext.fetchWords")
					let lastWordUsed = try manageContext.fetch(fetchWords)
					
					
					let addWord = Words(context: manageContext)
					addWord.sentenceID = newID
					addWord.word = wordCard.word
					addWord.sentenceID = newID
					print("[debug] PreviewStoryView, sentenceID \(newID)")
					addWord.wordChanged = Date()
					addWord.order = Int16(wordOrderCount)
					//find picture used for this word
					
					if lastWordUsed.count > 0 {
						//use the same picture
						addWord.picID = lastWordUsed.first?.picID
					} else {
						//add new word and add new picture item
						let newPicID = UUID()
						addWord.picID = newPicID
						let newPic = Pictures(context: manageContext)
						newPic.id = newPicID
						newPic.type = PictureSource.icon.rawValue
						newPic.iconURL = wordCard.iconURL
					}
					try manageContext.save()
					
					//after have added the word with pic, it's safe to delete the same word without sentenceID
					let fetchDanglingWords = NSFetchRequest<Words>(entityName: "Words")
					fetchDanglingWords.predicate = NSPredicate(format: "(word == %@) AND (sentenceID == nil)", wordCard.word)
					do {
						let wordWithoutSentence = try manageContext.fetch(fetchDanglingWords)
						for danglingWord in wordWithoutSentence {
							manageContext.delete(danglingWord)
						}
						try manageContext.save()
					} catch let error as NSError {
						print("Could not fetch. \(error), \(error.userInfo)")
					}
				}
				
				showSequenceActionView = false
				if showStoryNow {
					showStoryboard = true
				}
			} else {
				showSaveErrorAlert = true
				saveError = "Duplicate sentence."
			}
		} catch {
			// Replace this implementation with code to handle the error appropriately.
			// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			showSaveErrorAlert = true
			saveError = "Error occurs. The new sentence can not be saved."
			let nsError = error as NSError
			fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
		}
	}
	
	private func resizeImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
			var scale: CGFloat
			if image.size.width > image.size.height {
					scale = maxDimension / image.size.width
			} else {
					scale = maxDimension / image.size.height
			}
			
			let newWidth = image.size.width * scale
			let newHeight = image.size.height * scale
			UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
			image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
			let newImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()

			return newImage!
	}
}

#Preview {
	PreviewStoryView(showSequenceActionView: .constant(false), showStoryboard: .constant(false))
		.environmentObject(Sequencer())
}
