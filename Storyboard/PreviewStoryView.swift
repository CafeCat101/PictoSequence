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
					Task {
						await saveSequence(showStoryNow: false)
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
						await saveSequence(showStoryNow: true)
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
				let newID = UUID().uuidString
				let newItem = Sentences(context: manageContext)
				newItem.user_question = sequencer.theStoryByUser.sentence
				newItem.id = newID
				newItem.change_date = Date()
				try manageContext.save()
				
				//createPicturesFolder()
				for wordCard in sequencer.theStoryByUser.visualizedSequence {
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
		
		/*let destPictureURL = URL(string: "pictures", relativeTo: FileManager.documentoryDirecotryURL)!
		do {
			print("[debug] saveJpg destCourseURL:\(destPictureURL.path)")
			var isDirectory = ObjCBool(true)
			if FileManager.default.fileExists(atPath: destPictureURL.path, isDirectory: &isDirectory) == false {
				try FileManager.default.createDirectory(atPath: destPictureURL.path, withIntermediateDirectories: true)
			}
		} catch {
			print("[debug] saveJpg, check create destPictureURL, catch \(error)")
		}*/
		
		/*var isDirectory = ObjCBool(true)
		if FileManager.default.fileExists(atPath: FileManager.picturesDirectoryURL!.path, isDirectory: &isDirectory) == true {
			let saveToURL = URL(fileURLWithPath: "\(imageFileName)", relativeTo: FileManager.picturesDirectoryURL).appendingPathExtension(fileExtension)
			try? imgData.write(to: saveToURL)
			print("[debug] saveJpg, saveToURL \(saveToURL)")
		}*/
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
			}
		}
	}
	
	private func createPicturesFolder() {
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
	}
}
	/*#Preview {
		PreviewStoryView(showSequenceActionView: .constant(false), showStoryboard: .constant(false))
			.environmentObject(Sequencer())
	}*/
