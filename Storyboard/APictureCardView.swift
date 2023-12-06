//
//  APictureCardView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/11/4.
//

import SwiftUI
import CoreData

struct APictureCardView: View {
	//var word:String = "pic"
	@EnvironmentObject var sequencer:Sequencer
	@Environment(\.colorScheme) var colorScheme
	@Environment(\.managedObjectContext) private var manageContext
	
	var wordCard:WordCard
	var picWidth:CGFloat = 200
	var picHeight:CGFloat = 200
	@Binding var storyViewMode:StoryViewMode
	//var editMode = false
	
	@State private var showPic = true
	//@State private var sourceType:PictureSource = .icon
	@State private var showPhotoPicker = false
	@State private var showCaptureView = false
	@StateObject private var cameraDataModel = DataModel()
	@StateObject private var viewModel = PictureModel()
	//@State private var selectedChangedPhoto:Image? //this is for PhotoPicker and Live Camera Capture only
	@State private var showChangePictureView = false
	@StateObject private var pictureOptionsModel = PictureOptionsByWord()
	@StateObject private var iconOptionsModel = PictureOptionsByWord()
	@State private var showUpdateTheSameWordAlert = false
	@State private var newCard:WordCard = WordCard()
	
	
	var body: some View {
		VStack {
			pictureContainer()
				.modifier(photoStyle(getPicWidth: picWidth, getPicHeight: picHeight))
				.onTapGesture {
					showPic = false
				}
				.opacity(showPic ? 1 : 0)
				.disabled(showPic ? false : true)
				.onReceive(viewModel.transferableDone, perform: { result in
					print("[debug] APictureCardView, onRecieve viewModel.transferableDone \(viewModel.selectToUse)")
					if result == true && viewModel.selectToUse == true {
						cameraDataModel.thumbnailImage = nil
						newCard = WordCard()
						newCard = wordCard
						newCard.pictureID = UUID()
						newCard.pictureLocalPath = "pictures/\(newCard.pictureID.uuidString).jpg"
						newCard.pictureType = .photoPicker
						newCard.photo = UIImage(data: viewModel.selectedImageData!)
						
						onRecieveDataToAlert()
					}
				})
				.onReceive(cameraDataModel.capturedImageDone, perform: {result in
					newCard = WordCard()
					newCard.pictureID = UUID()
					newCard.pictureLocalPath = "pictures/\(newCard.pictureID.uuidString).jpg"
					newCard.pictureType = .camera
					newCard.photo = UIImage(data: cameraDataModel.thumbnailImageData!)
					
					onRecieveDataToAlert()
				})
				.onReceive(pictureOptionsModel.pictureSelected, perform: { result in
					if result.pictureType == .icon {
						viewModel.selectedImage = nil
						cameraDataModel.thumbnailImage = nil
					} else if result.pictureType == .photoPicker {
						cameraDataModel.thumbnailImage = nil
					} else if result.pictureType == .camera {
						viewModel.selectedImage = nil
					}
					
					newCard = WordCard()
					newCard.pictureID = result.id
					newCard.pictureLocalPath = result.localPicturePath
					newCard.pictureType = result.pictureType
					newCard.photo = result.image
					
					onRecieveDataToAlert()
				})
				.onReceive(iconOptionsModel.pictureSelected, perform: { result in
					print("[debug] APictureCardView, .onReceive:iconOptionsModel.pictureSelected")
					if result.pictureType == .icon {
						viewModel.selectedImage = nil
						cameraDataModel.thumbnailImage = nil
					} else if result.pictureType == .photoPicker {
						cameraDataModel.thumbnailImage = nil
					} else if result.pictureType == .camera {
						viewModel.selectedImage = nil
					}
					
					newCard = WordCard()
					newCard.pictureID = result.id
					newCard.pictureLocalPath = result.localPicturePath
					newCard.pictureType = result.pictureType
					newCard.photo = result.image
					newCard.iconURL = result.iconURL
					
					onRecieveDataToAlert()
				})
		}
		.overlay(content: {
			if showPic == false {
				VStack(spacing:0) {
					Spacer()
					HStack(spacing:0){
						Spacer()
						Text(wordCard.word)
							.font(.headline)
							.padding()
							.foregroundColor(.white)
						Spacer()
					}
					Spacer()
				}
				.frame(minWidth: picWidth, minHeight: picHeight)
				.background {
					RoundedRectangle(cornerRadius: 15)
						.foregroundColor(.black)
				}
				.onTapGesture {
					showPic = true
				}
				.opacity(showPic ? 0 : 1)
				.disabled(showPic ? true : false)
			}
		})
		.contextMenu(ContextMenu(menuItems: {
			if storyViewMode == .editSentence || storyViewMode == .newSentence {
				Button(action: {
					showChangePictureView = true
				}, label: {
					Text("Change picture")
				})
				
				Button(action: {
					viewModel.selectToUse = true
					showPhotoPicker.toggle()
				}, label: {
					Text("Select a photo")
				})
				
				Button(action: {
					showCaptureView = true
				}, label: {
					Text("Take a new picture")
				})
			}
		}))
		.photosPicker(isPresented: $showPhotoPicker ,selection: $viewModel.imageSelection, matching: .any(of: [.images, .livePhotos]))
		.fullScreenCover(
			isPresented: $showCaptureView, content: {
				CameraView(model:cameraDataModel, showCaptureView: $showCaptureView, viewModel: viewModel)
			})
		.sheet(
			isPresented: $showChangePictureView, content: {
				ChangePictureView(wordCard: wordCard, showChangePictureView: $showChangePictureView, pictureOptionsModel: pictureOptionsModel, iconOoptionsModel: iconOptionsModel)
			})
		.alert("Change Picture", isPresented: $showUpdateTheSameWordAlert, actions: {
			Button("Yes", action:{
				withAnimation {
					updateStoryByUserSequence(newWordCard: newCard, allTheSameWords: true)
				}
				showUpdateTheSameWordAlert = false
			})
			Button("No, only this", action:{
				withAnimation {
					updateStoryByUserSequence(newWordCard: newCard, allTheSameWords: false)
				}
				showUpdateTheSameWordAlert = false
			})
		}, message: {
			Text("Do you want to apply the changes to all the words \"\(wordCard.word)\" in this sentence?")
		})
	}
	
	struct photoStyle: ViewModifier {
		@Environment(\.colorScheme) var colorScheme
		var getPicWidth: CGFloat = 200
		var getPicHeight: CGFloat = 200
		
		func body(content: Content) -> some View {
			content
				.frame(width: getPicWidth, height: getPicHeight)
				.clipShape(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15)))
				.background {
					RoundedRectangle(cornerRadius: 15)
						.foregroundColor(Color("word_icon_bg"))
						.opacity(colorScheme == .dark ? 0.5 : 0.8)
						.shadow(color: .black, radius: 5)
				}
		}
	}
	
	@ViewBuilder
	private func pictureContainer() -> some View {
		/*if selectedChangedPhoto != nil {
			selectedChangedPhoto!
				.resizable()
				.scaledToFill()
		} else {
			displayImageFromFile()
		}*/
		displayImageFromFile()
	}
	
	@ViewBuilder
	private func displayImageFromFile() -> some View {
		if pictureExists(localPath: wordCard.pictureLocalPath) {
			let pictureURL = FileManager.documentoryDirecotryURL.appending(component: wordCard.pictureLocalPath)
			if wordCard.pictureType == .icon {
				Image(uiImage: UIImage(contentsOfFile: pictureURL.path())!)
					.resizable()
					.scaledToFit()
					.padding()
					.overlay(alignment: .center, content: {
						if sequencer.isPictureMissing(remoteURL: wordCard.iconURL) {
							Text("No Picture").bold()
						}
					})
					.onAppear(perform: {
						print("[debug] APictureCardView, displayImageFromFile, onAppear (fileExists \(wordCard.word)) \(wordCard.pictureLocalPath)")
					})
					.onChange(of: wordCard, perform: { wordCard in
						print("[debug] APictureCardView, displayImageFromFile, onChange (fileExists \(wordCard.word)) \(wordCard.pictureLocalPath)")
					})
			} else {
				Image(uiImage: UIImage(contentsOfFile: pictureURL.path())!)
					.resizable()
					.scaledToFill()
					.onAppear(perform: {
						print("[debug] APictureCardView, displayImageFromFile, onAppear (fileExists \(wordCard.word)) \(wordCard.pictureLocalPath)")
					})
					.onChange(of: wordCard, perform: { wordCard in
						print("[debug] APictureCardView, displayImageFromFile, onChange (fileExists \(wordCard.word)) \(wordCard.pictureLocalPath)")
					})
			}
			
		} else {
			if wordCard.pictureType == .camera || wordCard.pictureType == .photoPicker {
				if wordCard.photo != nil {
					//for photopicker and camera capturing live
					Image(uiImage: wordCard.photo!)
						.resizable()
						.scaledToFill()
						.onAppear(perform: {
							print("[debug] APictureCardView, displayImageFromFile, wordCard.photo.onAppear (fileExists \(wordCard.word)) \(wordCard.pictureLocalPath)")
						})
						.onChange(of: wordCard, perform: { wordCard in
							print("[debug] APictureCardView, displayImageFromFile, wordCard.photo.onChange (fileExists \(wordCard.word)) \(wordCard.pictureLocalPath)")
						})
				} else {
					AsyncImage(url: URL(string: wordCard.iconURL)) { phase in
						if let image = phase.image {
							image
								.resizable()
								.scaledToFit()
								.padding()
								.overlay(alignment: .center, content: {
									if sequencer.isPictureMissing(remoteURL: wordCard.iconURL) {
										Text("No Icon").bold()
									}
								})
								.onAppear(perform: {
									print("[debug] APictureCardView, displayImageFromFile, AsyncImage.onAppear, word \(wordCard.word) \(wordCard.pictureLocalPath)")
								})
						} else if phase.error != nil {
							Text("There was an error loading the image.")
						} else {
							ProgressView()
								.onAppear(perform: {
									print("[debug] APictureCardView, displayImageFromFile, AsyncImage-ProgressView() word \(wordCard.word) \(wordCard.pictureLocalPath)")
								})
						}
					}
				}
			} else {
				AsyncImage(url: URL(string: wordCard.iconURL)) { phase in
					if let image = phase.image {
						image
							.resizable()
							.scaledToFit()
							.padding()
							.overlay(alignment: .center, content: {
								if sequencer.isPictureMissing(remoteURL: wordCard.iconURL) {
									Text("No Icon").bold()
								}
							})
							.onAppear(perform: {
								print("[debug] APictureCardView, displayImageFromFile, AsyncImage.onAppear, word \(wordCard.word) \(wordCard.pictureLocalPath)")
							})
					} else if phase.error != nil {
						Text("There was an error loading the image.")
					} else {
						ProgressView()
							.onAppear(perform: {
								print("[debug] APictureCardView, displayImageFromFile, AsyncImage-ProgressView() word \(wordCard.word) \(wordCard.pictureLocalPath)")
							})
					}
				}
			}
			
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
	
	private func doesWordHavePhoto() -> [Pictures]? {
		let fetchWords = NSFetchRequest<Words>(entityName: "Words")
		fetchWords.predicate = NSPredicate(format: "word = %@", wordCard.word)
		fetchWords.sortDescriptors = [NSSortDescriptor(keyPath: \Words.wordChanged, ascending: false)]
		//var findPicID = ""
		var coreDataPicturesObj:[Pictures] = []
		
		do {
			let findWords = try manageContext.fetch(fetchWords)
			if findWords.count > 0 {
				for coreDataWord in findWords {
					let fetchPictures = NSFetchRequest<Pictures>(entityName: "Pictures")
					fetchPictures.predicate = NSPredicate(format: "id = %@ AND (type = %@ OR type = %@)", coreDataWord.picID ?? "", PictureSource.photoPicker.rawValue, PictureSource.camera.rawValue)
					let findPhotos = try manageContext.fetch(fetchPictures)
					
					if findPhotos.count > 0 {
						coreDataPicturesObj = findPhotos
						//findPicID = findPhotos.first?.id ?? ""
						break
					}
				}
			}
		} catch {
			
		}
		//return findPicID
		if coreDataPicturesObj.first?.id == wordCard.pictureID.uuidString {
			return []
		} else {
			return coreDataPicturesObj
		}
	}
	
	private func doesWordHaveImages() -> [Pictures]? {
		let fetchWords = NSFetchRequest<Words>(entityName: "Words")
		fetchWords.predicate = NSPredicate(format: "word = %@", wordCard.word)
		fetchWords.sortDescriptors = [NSSortDescriptor(keyPath: \Words.wordChanged, ascending: false)]
		//var findPicID = ""
		var coreDataPicturesObj:[Pictures] = []
		var trackPicID:[String] = []
		do {
			let findWords = try manageContext.fetch(fetchWords)
			if findWords.count > 0 {
				for coreDataWord in findWords {
					let fetchPictures = NSFetchRequest<Pictures>(entityName: "Pictures")
					fetchPictures.predicate = NSPredicate(format: "id = %@", coreDataWord.picID ?? "")
					let findPhotos = try manageContext.fetch(fetchPictures)
					
					if findPhotos.count > 0 {
						print("[debug] APictureCarVide picture.id \(findPhotos.first?.id ?? "") [\(trackPicID)]")
						if trackPicID.contains(where: {$0 == findPhotos.first?.id ?? ""}) == false {
							coreDataPicturesObj = findPhotos
							trackPicID.append(findPhotos.first?.id ?? "")
						}
					}
				}
			}
		} catch {
			
		}
		//return findPicID
		if coreDataPicturesObj.first?.id == wordCard.pictureID.uuidString {
			return []
		} else {
			return coreDataPicturesObj
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
	
	private func setAllIconOptions() {
		let fetchPictures = NSFetchRequest<Pictures>(entityName: "Pictures")
		fetchPictures.predicate = NSPredicate(format: "type = %@ AND word =  %@", PictureSource.icon.rawValue, wordCard.word)
		do {
			let findIcons = try manageContext.fetch(fetchPictures)
			if findIcons.count > 0 {
				//this sentence is saved before, has icons in the coredata
				for iconItem in findIcons {
					var iconOption = MyImage()
					iconOption.iconURL = iconItem.iconURL ?? ""
					iconOption.pictureType = .icon
					iconOption.localPicturePath = sequencer.getLocalPictureURLPath(remoteURL: iconItem.pictureLocalPath ?? "")
					if pictureExists(localPath: iconItem.pictureLocalPath ?? "") {
						let pictureURL = FileManager.documentoryDirecotryURL.appending(component: iconItem.pictureLocalPath ?? "")
						iconOption.image = UIImage(contentsOfFile: pictureURL.path())
					}
					iconOptionsModel.availablePictures.append(iconOption)
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
								iconOptionsModel.availablePictures.append(iconOption)
							}
							
						}
					}
				}
			}
		} catch {
			
		}
		
	}
	
	/*
	@ViewBuilder
	private func useMyPhotoButton() -> some View {
		let getPicID = doesWordHavePhoto()
		
		Button(action: {
			
		}, label: {
			Label(title: Text("Use my saved photo"), icon: {
				Image(uiImage: UIImage(contentsOfFile: ""))
					.resizable()
					.scaledToFit()
			})
		})
		
		
		let fetchPictures = NSFetchRequest<Pictures>(entityName: "Pictures")
		fetchPictures.predicate = NSPredicate(format: "id = %@", getPicID)
		let getPictures = try manageContext.fetch(fetchPictures)
		if getPictures.count > 0 {
			if getPicID.isEmpty == false {
				Button(action: {
					
				}, label: {
					Label(title: Text("Use my saved photo"), icon: {
						Image(uiImage: UIImage(contentsOfFile: ""))
							.resizable()
							.scaledToFit()
					})
				})
			} else {
				EmptyView()
			}
		} else {
			EmptyView()
		}
		
		
	}
	 */
	
	private func localPictureURLPath(pictureURLString: String) -> String {
		let pictureURL = FileManager.documentoryDirecotryURL.appending(component: pictureURLString)
		return pictureURL.path()
	}
	
	private func updateStoryByUserSequence(newWordCard: WordCard, allTheSameWords: Bool) {
		if allTheSameWords {
			for(index, wordCardItem) in sequencer.theStoryByUser.visualizedSequence.enumerated() {
				if wordCardItem.word == self.wordCard.word {
					print("[debug] APictureCardView, updateStoryByUserSequence, index \(index)")
					sequencer.theStoryByUser.visualizedSequence[index].pictureID = newWordCard.pictureID
					sequencer.theStoryByUser.visualizedSequence[index].pictureLocalPath = newWordCard.pictureLocalPath
					sequencer.theStoryByUser.visualizedSequence[index].pictureType = newWordCard.pictureType
					sequencer.theStoryByUser.visualizedSequence[index].photo = newWordCard.photo
					if sequencer.theStoryByUser.visualizedSequence[index].pictureType == PictureSource.icon {
						sequencer.theStoryByUser.visualizedSequence[index].iconURL = newWordCard.iconURL
					}
				}
			}
		} else {
			let wordCardIndex = sequencer.theStoryByUser.visualizedSequence.firstIndex(where: {$0.cardOrder == wordCard.cardOrder}) ?? -1
			if wordCardIndex > -1 {
				print("[debug] APictureCardView, updateStoryByUserSequence, wordCardIndex \(wordCardIndex)")
				sequencer.theStoryByUser.visualizedSequence[wordCardIndex].pictureID = newWordCard.pictureID
				sequencer.theStoryByUser.visualizedSequence[wordCardIndex].pictureLocalPath = newWordCard.pictureLocalPath
				sequencer.theStoryByUser.visualizedSequence[wordCardIndex].pictureType = newWordCard.pictureType
				sequencer.theStoryByUser.visualizedSequence[wordCardIndex].photo = newWordCard.photo
				if sequencer.theStoryByUser.visualizedSequence[wordCardIndex].pictureType == PictureSource.icon {
					sequencer.theStoryByUser.visualizedSequence[wordCardIndex].iconURL = newWordCard.iconURL
				}
			}
		}
		
		if showPic == false {
			showPic = true
		}
	}
	
	private func askApplyChangestoAllTheSameWords() -> Bool {
		let findSameWords = sequencer.theStoryByUser.visualizedSequence.filter({$0.word == wordCard.word})
		if findSameWords.count == 1 {
			return false
		} else {
			return true
		}
	}
	
	private func onRecieveDataToAlert() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
			if askApplyChangestoAllTheSameWords() {
				showUpdateTheSameWordAlert = true
			} else {
				withAnimation {
					updateStoryByUserSequence(newWordCard: newCard, allTheSameWords: false)
				}
			}
		}
	}
}

/*#Preview {
 APictureCardView()
 }*/
