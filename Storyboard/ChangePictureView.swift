//
//  ChangePictureView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/11/21.
//

import SwiftUI
import CoreData
import Combine

struct ChangePictureView: View {
	@Environment(\.managedObjectContext) private var manageContext
	@Environment(\.colorScheme) var colorScheme
	@EnvironmentObject var sequencer:Sequencer
	//@State private var pickerSelection = 1
	//@State private var mySavedPictures:[MyImage] = []
	
	@State var wordCard:WordCard = WordCard()
	@Binding var showChangePictureView:Bool
	@ObservedObject var pictureOptionsModel:PictureOptionsByWord
	@ObservedObject var iconOoptionsModel:PictureOptionsByWord
	
	var body: some View {
		VStack {
			HStack {
				Button(action: {
					showChangePictureView = false
				}, label: {
					Text("Cancel")
						.bold()
				})
				Spacer()
				/*
				 Picker(selection: $pickerSelection, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/) {
				 Text("All Icons").tag(1)
				 Text("Saved Pictures").tag(2)
				 }
				 .pickerStyle(.segmented)
				 
				 Spacer()*/
			}.padding([.top,.leading,.trailing], 15)
			
			Text(wordCard.word)
				.font(.title)
				.bold()
				.padding([.leading,.trailing], 30)
			
			ScrollView(.vertical) {
				HStack {
					Text("Your Saved Pictures")
						.font(.title2)
						.bold()
					Spacer()
				}
				.padding([.leading,.trailing], 15)
				AllSavedPictureView(card: wordCard, savedPictureModel: pictureOptionsModel, showChangePictureView: $showChangePictureView)
					.padding([.leading,.trailing], 15)
				
				HStack {
					Text("Icons Collection")
						.font(.title2)
						.bold()
					Spacer()
				}
				.padding([.leading,.trailing], 15)
				ChangePictureAllIconsView(card: wordCard, iconOptionsModel: iconOoptionsModel, showChangePictureView: $showChangePictureView)
					.padding([.leading,.trailing], 15)
			}
			
			Spacer()
		}
		.onAppear(perform: {
			setMySavedPictures()
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
				setAllIconOptions()
			}
		})
		.foregroundColor(Color("testColor2"))
		.background(
			Image(colorScheme == .light ? "vellum_sketchbook_paper" : "balck_canvas_bg4").resizable()
				.aspectRatio(contentMode: .fill)
				.edgesIgnoringSafeArea(.all))
	}
	
	private func setAllIconOptions() {
		if iconOoptionsModel.availablePictures.count > 0 {
			iconOoptionsModel.availablePictures = []
		}
		
		let fetchPictures = NSFetchRequest<Pictures>(entityName: "Pictures")
		fetchPictures.predicate = NSPredicate(format: "type = %@ AND word =  %@", PictureSource.icon.rawValue, wordCard.word)
		do {
			let findIcons = try manageContext.fetch(fetchPictures)
			if findIcons.count > 0 {
				//this sentence is saved before, has icons in the coredata
				for iconItem in findIcons {
					var iconOption = MyImage()
					iconOption.id = UUID(uuidString: iconItem.id ?? "") ?? UUID()
					iconOption.iconURL = iconItem.iconURL ?? ""
					iconOption.pictureType = .icon
					iconOption.localPicturePath = sequencer.getLocalPictureURLPath(remoteURL: iconItem.pictureLocalPath ?? "")
					if pictureExists(localPath: iconItem.pictureLocalPath ?? "") {
						let pictureURL = FileManager.documentoryDirecotryURL.appending(component: iconItem.pictureLocalPath ?? "")
						iconOption.image = UIImage(contentsOfFile: pictureURL.path())
					}
					iconOoptionsModel.availablePictures.append(iconOption)
				}
			} else {
				//this sentence is not saved yet, can be just a newly generated sentence
				if sequencer.theStoryByUser.sentence == sequencer.theStoryByAI.sentence {
					if sequencer.theStoryByAI.visualizedSequence.count > 0 {
						let findTheSequence = sequencer.theStoryByAI.visualizedSequence.first(where: {$0.words[0].word == wordCard.word})
						let findPictures = findTheSequence?.words[0].pictures ?? []
						if findPictures.count > 0 {
							for pictureItem in findPictures {
								var iconOption = MyImage()
								iconOption.iconURL = pictureItem.thumbnail_url
								iconOption.pictureType = .icon
								iconOption.localPicturePath = sequencer.getLocalPictureURLPath(remoteURL: pictureItem.thumbnail_url)
								iconOoptionsModel.availablePictures.append(iconOption)
							}
						}
					}
				}
			}
		} catch {
			
		}
		
	}
	private func setMySavedPictures() {
		let fetchWords = NSFetchRequest<Words>(entityName: "Words")
		fetchWords.predicate = NSPredicate(format: "word = %@", wordCard.word)
		fetchWords.sortDescriptors = [NSSortDescriptor(keyPath: \Words.wordChanged, ascending: false)]
		var trackPicID:[String] = []
		
		do {
			let findWords = try manageContext.fetch(fetchWords)
			if findWords.count > 0 {
				if pictureOptionsModel.availablePictures.count > 0 {
					pictureOptionsModel.availablePictures = []
				}
				
				for coreDataWord in findWords {
					let fetchPictures = NSFetchRequest<Pictures>(entityName: "Pictures")
					fetchPictures.predicate = NSPredicate(format: "id = %@", coreDataWord.picID ?? "")
					let findPhotos = try manageContext.fetch(fetchPictures)
					
					if findPhotos.count > 0 {
						print("[debug] ChangePictureView, \(wordCard.word) picture.id \(findPhotos.first?.id ?? "") [\(trackPicID)]")
						if trackPicID.contains(where: {$0 == findPhotos.first?.id ?? ""}) == false {
							trackPicID.append(findPhotos.first?.id ?? "")
							
							if pictureExists(localPath: findPhotos.first?.pictureLocalPath ?? "") {
								let pictureURL = FileManager.documentoryDirecotryURL.appending(component: findPhotos.first?.pictureLocalPath ?? "")
								var myPicture = MyImage()
								myPicture.id = UUID(uuidString: findPhotos.first?.id ?? "") ?? UUID()
								myPicture.image = UIImage(contentsOfFile: pictureURL.path())
								myPicture.localPicturePath = findPhotos.first?.pictureLocalPath ?? ""
								let picType = findPhotos.first?.type ?? ""
								if picType == PictureSource.photoPicker.rawValue {
									myPicture.pictureType = .photoPicker
								} else if picType == PictureSource.camera.rawValue {
									myPicture.pictureType = .camera
								}
								myPicture.iconURL = findPhotos.first?.iconURL ?? ""
								pictureOptionsModel.availablePictures.append(myPicture)
								
								print("[debug] ChangePictureView, append Image \(pictureURL.path())")
								print("[debug] ChangePictureView, mySavedImage.count \(pictureOptionsModel.availablePictures.count)")
							} else {
								print("[debug] ChangePictureView, \(findPhotos.first?.pictureLocalPath ?? "") pictureExists=false")
							}
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
	
	/*
	private func setMySavedPictures() {
		let fetchWords = NSFetchRequest<Words>(entityName: "Words")
		fetchWords.predicate = NSPredicate(format: "word = %@", wordCard.word)
		fetchWords.sortDescriptors = [NSSortDescriptor(keyPath: \Words.wordChanged, ascending: false)]
		var trackPicID:[String] = []
		
		do {
			let findWords = try manageContext.fetch(fetchWords)
			if findWords.count > 0 {
				for coreDataWord in findWords {
					let fetchPictures = NSFetchRequest<Pictures>(entityName: "Pictures")
					fetchPictures.predicate = NSPredicate(format: "id = %@", coreDataWord.picID ?? "")
					let findPhotos = try manageContext.fetch(fetchPictures)
					
					if findPhotos.count > 0 {
						print("[debug] ChangePictureView, \(wordCard.word) picture.id \(findPhotos.first?.id ?? "") [\(trackPicID)]")
						if trackPicID.contains(where: {$0 == findPhotos.first?.id ?? ""}) == false {
							trackPicID.append(findPhotos.first?.id ?? "")
							
							if pictureExists(localPath: findPhotos.first?.pictureLocalPath ?? "") {
								let pictureURL = FileManager.documentoryDirecotryURL.appending(component: findPhotos.first?.pictureLocalPath ?? "")
								let myPicture = MyImage(image: Image(uiImage: UIImage(contentsOfFile: pictureURL.path())!), localPicturePath: findPhotos.first?.pictureLocalPath ?? "")
								mySavedPictures.append(myPicture)
								print("[debug] ChangePictureView, append Image \(pictureURL.path())")
								print("[debug] ChangePictureView, mySavedImage.count \(mySavedPictures.count)")
							} else {
								print("[debug] ChangePictureView, \(findPhotos.first?.pictureLocalPath ?? "") pictureExists=false")
							}
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
	 */
}

#Preview {
	ChangePictureView(showChangePictureView: .constant(false), pictureOptionsModel: PictureOptionsByWord(), iconOoptionsModel: PictureOptionsByWord())
}
