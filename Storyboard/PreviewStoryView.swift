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
	@Binding var storyViewMode:StoryViewMode
	//var editMode = false
	
	@State private var showSaveErrorAlert = false
	@State private var saveError = ""
	
	var body: some View {
		VStack {
			Text(sequencer.theStoryByUser.sentence)
				.font(.title2)
				.bold()
				.padding([.leading,.trailing], 15)
			StoryView(storyViewMode: $storyViewMode)
				.background {
					RoundedRectangle(cornerRadius: 10)
						.foregroundColor(.brown)
						.opacity(0.3)
				}
				.padding(15)
			
			HStack {
				Spacer()
				Button(action: {
					Task {
						if storyViewMode == .newSentence {
							await saveSequence(showStoryNow: false)
						} else if storyViewMode == .editSentence {
							await editSequence(showStoryNow: false)
						}
					}
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
					Task {
						if storyViewMode == .newSentence {
							await saveSequence(showStoryNow: true)
						} else if storyViewMode == .editSentence {
							await editSequence(showStoryNow: true)
						}
					}
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
			print("[debug] PreviewStoryView, onAppear, sequencer.theStoryByUser.sentence \(sequencer.theStoryByUser.sentence)")
		})
	}
	
	
	private func saveSequence(showStoryNow: Bool) async {
		do {
			fetchRequest.predicate = NSPredicate(format: "user_question = %@", sequencer.theStoryByUser.sentence)
			let existedSentences = try manageContext.fetch(fetchRequest)
			if existedSentences.count == 0 {
				let newSentenceID = UUID().uuidString
				let newItem = Sentences(context: manageContext)
				newItem.user_question = sequencer.theStoryByUser.sentence
				newItem.id = newSentenceID
				newItem.change_date = Date()
				try manageContext.save()
				
				//every word in the sentence will have a new object associated with the new sentenceID
				for wordCard in sequencer.theStoryByUser.visualizedSequence {
					let addWord = Words(context: manageContext)
					addWord.sentenceID = newSentenceID
					addWord.word = wordCard.word
					print("[debug] PreviewStoryView, sentenceID \(newSentenceID)")
					addWord.wordChanged = Date()
					addWord.order = Int16(wordCard.cardOrder)
					addWord.picID = wordCard.pictureID.uuidString
					try manageContext.save()
					
					//check if a new picture object is requred
					let fecthPictures = NSFetchRequest<Pictures>(entityName: "Pictures")
					fecthPictures.predicate = NSPredicate(format: "id = %@", wordCard.pictureID.uuidString)
					fecthPictures.fetchLimit = 1
					let existingPictures = try manageContext.fetch(fecthPictures)
					if existingPictures.count == 0 {
						let newPic = Pictures(context: manageContext)
						newPic.id = wordCard.pictureID.uuidString
						newPic.word = wordCard.word
						newPic.type = wordCard.pictureType.rawValue
						newPic.pictureLocalPath = wordCard.pictureLocalPath
						newPic.iconURL = wordCard.iconURL
						try manageContext.save()
					}
					
					//save image to disk
					if pictureExists(localPath: wordCard.pictureLocalPath) == false {
						var isDirectory = ObjCBool(true)
						if FileManager.default.fileExists(atPath: FileManager.picturesDirectoryURL!.path, isDirectory: &isDirectory) == true {
							if wordCard.pictureType == .photoPicker || wordCard.pictureType == .camera {
								let resizedImage = resizeImage(image: wordCard.photo!, maxDimension: 1000)
								saveImageToDisk(saveImage: resizedImage, imageFileName: wordCard.pictureID.uuidString, asJPG: true)
							} else if wordCard.pictureType == .icon {
								try await downloadIcon(remoteIconURL: wordCard.iconURL, iconURL: wordCard.pictureLocalPath)
							}
						}
					}
					
					//**************************
					/*
					let fetchWords = NSFetchRequest<Words>(entityName: "Words")
					fetchWords.predicate = NSPredicate(format: "word = %@", wordCard.word)
					fetchWords.sortDescriptors = [NSSortDescriptor(keyPath: \Words.wordChanged, ascending: false)]
					fetchWords.fetchLimit = 1
					
					//find picture used for this word
					let lastWordUsed = try manageContext.fetch(fetchWords)
					
					let addWord = Words(context: manageContext)
					addWord.sentenceID = newID
					addWord.word = wordCard.word
					print("[debug] PreviewStoryView, sentenceID \(newID)")
					addWord.wordChanged = Date()
					addWord.order = Int16(wordCard.cardOrder)
					if lastWordUsed.count > 0 {
						//use the same picture
						addWord.picID = lastWordUsed.first?.picID
						try manageContext.save()
					} else {
						//add new word and add new picture item
						addWord.picID = wordCard.pictureID.uuidString
						let newPic = Pictures(context: manageContext)
						newPic.id = wordCard.pictureID.uuidString
						newPic.type = wordCard.pictureType.rawValue
						newPic.pictureLocalPath = wordCard.pictureLocalPath
						newPic.iconURL = wordCard.iconURL
						try manageContext.save()
						
						//after have added the word with pic, it's safe to delete the same word without sentenceID
						let fetchWordsWithoutSentenceID = NSFetchRequest<Words>(entityName: "Words")
						fetchWordsWithoutSentenceID.predicate = NSPredicate(format: "(word == %@) AND (sentenceID == nil)", wordCard.word)
						do {
							let wordWithoutSentence = try manageContext.fetch(fetchWordsWithoutSentenceID)
							for danglingWord in wordWithoutSentence {
								manageContext.delete(danglingWord)
							}
							try manageContext.save()
						} catch let error as NSError {
							print("Could not fetch. \(error), \(error.userInfo)")
						}
						
						//save image to disk
						var isDirectory = ObjCBool(true)
						if FileManager.default.fileExists(atPath: FileManager.picturesDirectoryURL!.path, isDirectory: &isDirectory) == true {
							if wordCard.pictureType == .photoPicker || wordCard.pictureType == .camera {
								let resizedImage = resizeImage(image: wordCard.photo!, maxDimension: 1000)
								saveImageToDisk(saveImage: resizedImage, imageFileName: wordCard.pictureID.uuidString, asJPG: true)
							} else if wordCard.pictureType == .icon {
								try await downloadIcon(remoteIconURL: wordCard.iconURL, iconURL: wordCard.pictureLocalPath)
							}
						}
						
					}
					*/
				}
				
				print("[debug] PreviewStoryView, AI sentence \(sequencer.theStoryByAI.sentence)")
				print("[debug] PreviewStoryView, User sentence \(sequencer.theStoryByUser.sentence)")
				if sequencer.theStoryByAI.sentence == sequencer.theStoryByUser.sentence {
					saveIconOptions()
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
	
	private func saveImageToDisk(saveImage: UIImage, imageFileName: String, asJPG: Bool) {
		var imgData = Data()
		var fileExtension = ""
		
		if asJPG {
			imgData = saveImage.jpegData(compressionQuality: 0.6)!
			fileExtension = "jpg"
		} else {
			imgData = saveImage.pngData()!
			fileExtension = "png"
		}

		let saveToURL = URL(fileURLWithPath: "\(imageFileName)", relativeTo: FileManager.picturesDirectoryURL).appendingPathExtension(fileExtension)
		if FileManager.default.fileExists(atPath: saveToURL.path()) == false {
			try? imgData.write(to: saveToURL)
			print("[debug] saveJpg, saveToURL \(saveToURL)")
		}
	}
	
	private func downloadIcon(remoteIconURL: String, iconURL: String) async throws {
		var iconDownloadTask: Task<URL?,Error>?
		let downloadableIconURL = URL(string: remoteIconURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
		
		let destIconURL = URL(string: iconURL, relativeTo: FileManager.documentoryDirecotryURL)!
		if FileManager.default.fileExists(atPath: destIconURL.path()) == false {
			iconDownloadTask = Task { () -> URL? in
				print("[debug] PreviewStoryView, downloadIcon \(remoteIconURL) to \(destIconURL.path())")
				let (fileURL, _) = try await URLSession.shared.download(from: downloadableIconURL)
				return fileURL
			}
			
			do {
				let getIconFileURL = try await iconDownloadTask!.value!
				print("[deubg] PreviewStoryView, downloadIcon(), getIconFileURL \(getIconFileURL)")
				try FileManager.default.moveItem(at: getIconFileURL, to: destIconURL)
				DispatchQueue.main.async {
					print("[debug] PreviewStoryView, downloadIcon(), moveItem at \(destIconURL.path())")
				}
			} catch {
				print("Error \(error)")
			}
		}
	}
	
	/*private func createPicturesFolder() {
		let destPictureURL = URL(string: "pictures", relativeTo: FileManager.documentoryDirecotryURL)!
		do {
			print("[debug] saveJpg destCourseURL:\(destPictureURL.path)")
			var isDirectory = ObjCBool(true)
			if FileManager.default.fileExists(atPath: destPictureURL.path, isDirectory: &isDirectory) == false {
				try FileManager.default.createDirectory(atPath: destPictureURL.path, withIntermediateDirectories: true)
			}
		} catch {
			print("[debug] saveJpg, check create destPictureURL, catch \(error)")
		}
	}*/
	
	private func editSequence(showStoryNow: Bool) async {
		do {
			fetchRequest.predicate = NSPredicate(format: "user_question = %@", sequencer.theStoryByUser.sentence)
			let existedSentences = try manageContext.fetch(fetchRequest)
			if existedSentences.count > 0 {
				for wordCard in sequencer.theStoryByUser.visualizedSequence {
					let fetchEditWords = NSFetchRequest<Words>(entityName: "Words")
					fetchEditWords.predicate = NSPredicate(format: "sentenceID = %@ AND word = %@", existedSentences.first?.id ?? "", wordCard.word)
					let findWord = try manageContext.fetch(fetchEditWords)
					if findWord.count > 0 {
						if findWord.first?.picID != wordCard.pictureID.uuidString {
							//piciture has changed
							findWord.first?.wordChanged = Date()
							findWord.first?.sentenceID = ""
							try manageContext.save()
							
							let addWord = Words(context: manageContext)
							addWord.sentenceID = existedSentences.first?.id ?? ""
							addWord.word = wordCard.word
							addWord.wordChanged = Date()
							addWord.order = Int16(wordCard.cardOrder)
							addWord.picID = wordCard.pictureID.uuidString
							try manageContext.save()
							
							//check if a new picture object is requred
							let fecthPictures = NSFetchRequest<Pictures>(entityName: "Pictures")
							fecthPictures.predicate = NSPredicate(format: "id = %@", wordCard.pictureID.uuidString)
							fecthPictures.fetchLimit = 1
							let existingPictures = try manageContext.fetch(fecthPictures)
							if existingPictures.count == 0 {
								let newPic = Pictures(context: manageContext)
								newPic.id = wordCard.pictureID.uuidString
								newPic.word = wordCard.word
								newPic.type = wordCard.pictureType.rawValue
								newPic.pictureLocalPath = wordCard.pictureLocalPath
								newPic.iconURL = wordCard.iconURL
								try manageContext.save()
							}
							
							if pictureExists(localPath: wordCard.pictureLocalPath) == false {
								//save image to disk
								var isDirectory = ObjCBool(true)
								if FileManager.default.fileExists(atPath: FileManager.picturesDirectoryURL!.path, isDirectory: &isDirectory) == true {
									if wordCard.pictureType == .photoPicker || wordCard.pictureType == .camera {
										let resizedImage = resizeImage(image: wordCard.photo!, maxDimension: 1000)
										saveImageToDisk(saveImage: resizedImage, imageFileName: wordCard.pictureID.uuidString, asJPG: true)
									} else if wordCard.pictureType == .icon {
										try await downloadIcon(remoteIconURL: wordCard.iconURL, iconURL: wordCard.pictureLocalPath)
									}
								}
							}
							
							clearDuplicatedIconRecord()
							
							//*********************
							/*
							findWord.first?.picID = wordCard.pictureID.uuidString
							findWord.first?.wordChanged = Date()
							//=>update this later, findWord.first?.wordChanged =
							let fetchPictures = NSFetchRequest<Pictures>(entityName: "Pictures")
							fetchPictures.predicate = NSPredicate(format: "id = %@", wordCard.pictureID.uuidString)
							let existingPictures = try manageContext.fetch(fetchPictures)
							if existingPictures.count == 0 {
								//a new image, should create a new picture object, save it and download the image to disk
								let newPic = Pictures(context: manageContext)
								newPic.id = wordCard.pictureID.uuidString
								newPic.type = wordCard.pictureType.rawValue
								newPic.pictureLocalPath = wordCard.pictureLocalPath
								newPic.iconURL = wordCard.iconURL
								
								//save image to disk
								var isDirectory = ObjCBool(true)
								if FileManager.default.fileExists(atPath: FileManager.picturesDirectoryURL!.path, isDirectory: &isDirectory) == true {
									if wordCard.pictureType == .photoPicker || wordCard.pictureType == .camera {
										let resizedImage = resizeImage(image: wordCard.photo!, maxDimension: 1000)
										saveImageToDisk(saveImage: resizedImage, imageFileName: wordCard.pictureID.uuidString, asJPG: true)
									} else if wordCard.pictureType == .icon {
										try await downloadIcon(remoteIconURL: wordCard.iconURL, iconURL: wordCard.pictureLocalPath)
									}
								}
							}
							try manageContext.save()
							 */
							//********************
						}
					} else {
						//should find the word in the sentence, but not finding it in CoreData
					}
				}
				
				showSequenceActionView = false
				if showStoryNow {
					showStoryboard = true
				}
			} else {
				showSaveErrorAlert = true
				saveError = "Can not find the sentence to edit."
			}
		} catch {
			showSaveErrorAlert = true
			saveError = "Error occurs. Unable to save editted sentence."
		}
	}
	
	private func clearDuplicatedIconRecord() {
		//in the order of word added first, remove word without sentenceID and use an icon that are added more than once.
		//preserver the latest word with that icon so "generate() in NewSequenceView will find the last used image(icon or photo) for that word. Sometimes a word object without the sentenceID can be created by deleting a sentence."
		let fetchWords = NSFetchRequest<Words>(entityName: "Words")
		fetchWords.predicate = NSPredicate(format: "sentenceID = %@", "")
		fetchWords.sortDescriptors = [NSSortDescriptor(keyPath: \Words.wordChanged, ascending: true)]
		do {
			let emptySentneceIDWords = try manageContext.fetch(fetchWords)
			if emptySentneceIDWords.count > 0 {
				let fetchWordsWithSamePicID = NSFetchRequest<Words>(entityName: "Words")
				for wordItem in emptySentneceIDWords {
					fetchWordsWithSamePicID.predicate = NSPredicate(format: "sentenceID = %@ AND picID = %@", "", wordItem.picID ?? "")
					let wordsWithSamePicID = try manageContext.fetch(fetchWordsWithSamePicID)
					let countWordsWithSamePicID = wordsWithSamePicID.count

					let fetchPictures = NSFetchRequest<Pictures>(entityName: "Pictures")
					fetchPictures.predicate = NSPredicate(format: "id = %@ AND type = %@", wordItem.picID ?? "", PictureSource.icon.rawValue)
					let findPictures = try manageContext.fetch(fetchPictures)
					
					if findPictures.count > 0 && countWordsWithSamePicID > 1 {
						manageContext.delete(wordItem)
						try manageContext.save()
					}
				}
			}
		} catch {
			
		}
		
		//let updateWords = try manageContext.fetch(fecthWords)
	}
	
	private func saveIconOptions() {
		let fetchPictures = NSFetchRequest<Pictures>(entityName: "Pictures")
		do {
			for sequenceItem in sequencer.theStoryByAI.visualizedSequence {
				for wordItem in sequenceItem.words {
					for picture in wordItem.pictures {
						fetchPictures.predicate = NSPredicate(format: "iconURL = %@ AND type = %@", picture.thumbnail_url, PictureSource.icon.rawValue)
						let findIcons = try manageContext.fetch(fetchPictures)
						print("[debug] PreviewStoryView, saveIconOptios(), findIcons.count \(findIcons.count)")
						if findIcons.count == 0 {
							let newPic = Pictures(context: manageContext)
							newPic.id = UUID().uuidString
							newPic.word = wordItem.word
							newPic.type = PictureSource.icon.rawValue
							newPic.iconURL = picture.thumbnail_url
							newPic.pictureLocalPath = sequencer.getLocalPictureURLPath(remoteURL: picture.thumbnail_url)
							try manageContext.save()
						}
					}
				}
			}
		} catch {
			
		}
		
	}
	
	private func pictureExists(localPath: String) -> Bool {
		//localPath is wordCard.pictureLocalPath
		let imageUrl = FileManager.documentoryDirecotryURL.appending(path: localPath)
		if FileManager.default.fileExists(atPath: imageUrl.path()) {
			return true
		} else {
			return false
		}
	}
}
	/*#Preview {
		PreviewStoryView(showSequenceActionView: .constant(false), showStoryboard: .constant(false))
			.environmentObject(Sequencer())
	}*/
