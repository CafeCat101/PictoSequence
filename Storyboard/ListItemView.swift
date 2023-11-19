//
//  ListItemView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/9/27.
//

import SwiftUI
import CoreData

struct ListItemView: View {
	@EnvironmentObject var sequencer:Sequencer
	@Environment(\.managedObjectContext) private var managedContext
	
	@Binding var showEditSequence:Bool
	var textLine:String = "Sequence"
	
	var body: some View {
		VStack {
			Text("\(textLine)")
		}
		.swipeActions {
			Button("Edit") {
				print("edit!")
				let fetchRequest = NSFetchRequest<Sentences>(entityName: "Sentences")
				fetchRequest.predicate = NSPredicate(format: "user_question == %@", textLine)
				
				do {
					let sentences = try managedContext.fetch(fetchRequest)
					let sentenceID = sentences.first?.id
					
					let fetchWords = NSFetchRequest<Words>(entityName: "Words")
					fetchWords.predicate = NSPredicate(format: "sentenceID = %@", sentenceID ?? "")
					fetchWords.sortDescriptors = [NSSortDescriptor(keyPath: \Words.order, ascending: true)]
					let allWords = try managedContext.fetch(fetchWords)
					if allWords.count > 0 {
						sequencer.theStoryByUser = StoryByUser()
						sequencer.theStoryByUser.sentence = sentences.first?.user_question ?? ""
						for wordItem in allWords {
							var addWordCard = WordCard()
							addWordCard.word = wordItem.word ?? ""
							addWordCard.cardOrder = Int(wordItem.order)
							print("\(String(describing: wordItem.word)) \(String(describing: wordItem.picID))")
							let fetchPictures = NSFetchRequest<Pictures>(entityName: "Pictures")
							fetchPictures.predicate = NSPredicate(format: "id = %@", wordItem.picID ?? "")
							fetchPictures.fetchLimit = 1
							let usePic = try managedContext.fetch(fetchPictures)
							if usePic.count > 0 {
								addWordCard.pictureID = UUID(uuidString: usePic.first?.id ?? "") ?? UUID()
								if usePic.first?.type == PictureSource.icon.rawValue {
									addWordCard.pictureType = .icon
								} else if usePic.first?.type == PictureSource.photoPicker.rawValue {
									addWordCard.pictureType = .photoPicker
								} else if usePic.first?.type == PictureSource.camera.rawValue {
									addWordCard.pictureType = .camera
								}
								addWordCard.iconURL = usePic.first?.iconURL ?? ""
								addWordCard.pictureLocalPath = usePic.first?.pictureLocalPath ?? ""
							}
							sequencer.theStoryByUser.visualizedSequence.append(addWordCard)
						}
						showEditSequence = true
					} else {
						//error
						print("[debug] fetchWords with \(textLine) has no item")
					}
				} catch {
					
				}
			}
			.tint(.green)
			
			Button("Delete") {
				print("delete!")
				withAnimation {
					let fetchRequest = NSFetchRequest<Sentences>(entityName: "Sentences")
					fetchRequest.predicate = NSPredicate(format: "user_question == %@", textLine)
					
					do {
						let sentences = try managedContext.fetch(fetchRequest)
						if sentences.count > 0 {
							let deleteSentenceID = sentences.first?.id ?? ""
							for sentence in sentences {
								managedContext.delete(sentence)
							}
							
							for wordCard in sequencer.theStoryByUser.visualizedSequence {
								let fetchSameWords = NSFetchRequest<Words>(entityName: "Words")
								fetchSameWords.predicate = NSPredicate(format: "word = %@ AND sentenceID = %@", wordCard.word, deleteSentenceID)
								let sameWords = try managedContext.fetch(fetchSameWords)
								print("[debug] ListItemView, delete, sameWords.count \(sameWords.count)")
								if sameWords.count > 0 {
									for wordItem in sameWords {
										print("[debug] ListItemView, delete, wordItem \(String(describing: wordItem.word))")
										wordItem.sentenceID = ""
									}
								}
							}
						}
						try managedContext.save()
						
						clearDuplicatedIconRecord()
					} catch let error as NSError {
						print("Could not fetch. \(error), \(error.userInfo)")
					}
				}
				
			}
			.tint(.red)
		}
		.foregroundColor(Color("testColor2"))
		.listRowBackground(Color.clear)
	}
	
	private func clearDuplicatedIconRecord() {
		//in the order of word added first, remove word without sentenceID and use an icon that are added more than once.
		//preserver the latest word with that icon so "generate() in NewSequenceView will find the last used image(icon or photo) for that word. Sometimes a word object without the sentenceID can be created by deleting a sentence."
		let fetchWords = NSFetchRequest<Words>(entityName: "Words")
		fetchWords.predicate = NSPredicate(format: "sentenceID = %@", "")
		fetchWords.sortDescriptors = [NSSortDescriptor(keyPath: \Words.wordChanged, ascending: true)]
		do {
			let emptySentneceIDWords = try managedContext.fetch(fetchWords)
			if emptySentneceIDWords.count > 0 {
				let fetchWordsWithSamePicID = NSFetchRequest<Words>(entityName: "Words")
				for wordItem in emptySentneceIDWords {
					fetchWordsWithSamePicID.predicate = NSPredicate(format: "sentenceID = %@ AND picID = %@", "", wordItem.picID ?? "")
					let wordsWithSamePicID = try managedContext.fetch(fetchWordsWithSamePicID)
					let countWordsWithSamePicID = wordsWithSamePicID.count

					let fetchPictures = NSFetchRequest<Pictures>(entityName: "Pictures")
					fetchPictures.predicate = NSPredicate(format: "id = %@ AND type = %@", wordItem.picID ?? "", PictureSource.icon.rawValue)
					let findPictures = try managedContext.fetch(fetchPictures)
					
					if findPictures.count > 0 && countWordsWithSamePicID > 1 {
						managedContext.delete(wordItem)
						try managedContext.save()
					}
				}
			}
		} catch {
			
		}
		
		//let updateWords = try manageContext.fetch(fecthWords)
	}
}

#Preview {
	ListItemView(showEditSequence: .constant(false))
}
