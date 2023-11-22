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
	
	@State var wordCard:WordCard = WordCard()
	var picWidth:CGFloat = 200
	var picHeight:CGFloat = 200
	var fromDatabase = false
	
	@State private var showPic = true
	@State private var sourceType:PictureSource = .icon
	@State private var showPhotoPicker = false
	@State private var showCaptureView = false
	@StateObject private var cameraDataModel = DataModel()
	@StateObject private var viewModel = PictureModel()
	@State private var editingCount = 0
	@State private var selectedChangedPhoto:Image?
	@State private var showChangePictureView = false
	
	
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
						selectedChangedPhoto = viewModel.selectedImage
						cameraDataModel.thumbnailImage = nil
						sourceType = .photoPicker
						wordCard.pictureID = UUID()
						wordCard.pictureLocalPath = "pictures/\(wordCard.pictureID.uuidString).jpg"
						wordCard.pictureType = .photoPicker
						wordCard.photo = UIImage(data: viewModel.selectedImageData!)
						
						let findCardIndex = sequencer.theStoryByUser.visualizedSequence.firstIndex(where: {$0.word == wordCard.word}) ?? -1
						if findCardIndex > -1 {
							sequencer.theStoryByUser.visualizedSequence[findCardIndex] = wordCard
						}
					}
				})
				.onReceive(cameraDataModel.capturedImageDone, perform: {result in
					selectedChangedPhoto = cameraDataModel.thumbnailImage
					wordCard.pictureID = UUID()
					wordCard.pictureLocalPath = "pictures/\(wordCard.pictureID.uuidString).jpg"
					wordCard.pictureType = .camera
					wordCard.photo = UIImage(data: cameraDataModel.thumbnailImageData!)
					
					let findCardIndex = sequencer.theStoryByUser.visualizedSequence.firstIndex(where: {$0.word == wordCard.word}) ?? -1
					if findCardIndex > -1 {
						sequencer.theStoryByUser.visualizedSequence[findCardIndex] = wordCard
					}
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
			Button(action: {
				showChangePictureView = true
			}, label: {
				Text("Change picture")
			})
			
			/*
			if wordCard.pictureType != .icon {
				Button(action: {
					selectedChangedPhoto = nil
					viewModel.selectedImage = nil
					cameraDataModel.thumbnailImage = nil
					sourceType = .icon
					//find existing icon, try not to create another picture object has the same icon
					let fecthPictures = NSFetchRequest<Pictures>(entityName: "Pictures")
					fecthPictures.predicate = NSPredicate(format: "type = %@ AND pictureLocalPath = %@", PictureSource.icon.rawValue, "pictures/\(sequencer.getImageFileName(remoteURL: wordCard.iconURL))")
					fecthPictures.fetchLimit = 1
					do {
						let existingIcons = try manageContext.fetch(fecthPictures)
						if existingIcons.count > 0 {
							wordCard.pictureID = UUID(uuidString: existingIcons.first?.id ?? "") ?? UUID()
						} else {
							wordCard.pictureID = UUID()
						}
					} catch {
						wordCard.pictureID = UUID()
					}
					
					wordCard.pictureLocalPath = "pictures/\(sequencer.getImageFileName(remoteURL: wordCard.iconURL))"
					wordCard.pictureType = .icon
					
					let findCardIndex = sequencer.theStoryByUser.visualizedSequence.firstIndex(where: {$0.word == wordCard.word}) ?? -1
					if findCardIndex > -1 {
						sequencer.theStoryByUser.visualizedSequence[findCardIndex] = wordCard
					}
				}, label: {
					Text("Use icon")
				})
			}
			*/
			/*
			if let myPhotos = doesWordHavePhoto(), myPhotos.count > 0 {
				Button(action: {
					selectedChangedPhoto = Image(uiImage: UIImage(contentsOfFile: localPictureURLPath(pictureURLString: myPhotos.first?.pictureLocalPath ?? "")) ?? UIImage())
					wordCard.pictureID = UUID(uuidString: myPhotos.first?.id ?? "") ?? UUID()
					wordCard.pictureLocalPath = myPhotos.first?.pictureLocalPath ?? ""
					if myPhotos.first?.type == PictureSource.photoPicker.rawValue {
						wordCard.pictureType = .photoPicker
						cameraDataModel.thumbnailImage = nil
					} else {
						wordCard.pictureType = .camera
					}
					wordCard.photo = UIImage(contentsOfFile: localPictureURLPath(pictureURLString: myPhotos.first?.pictureLocalPath ?? "")) ?? UIImage()
					
					let findCardIndex = sequencer.theStoryByUser.visualizedSequence.firstIndex(where: {$0.word == wordCard.word}) ?? -1
					if findCardIndex > -1 {
						sequencer.theStoryByUser.visualizedSequence[findCardIndex] = wordCard
					}
				}, label: {
					Label(title: {
						Text("Use my saved phpto")
					}, icon: {
						Image(uiImage: UIImage(contentsOfFile: localPictureURLPath(pictureURLString: myPhotos.first?.pictureLocalPath ?? "")) ?? UIImage())
							.resizable()
							.scaledToFill()
					})
				})
			}
			 */
			
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
		}))
		.photosPicker(isPresented: $showPhotoPicker ,selection: $viewModel.imageSelection, matching: .any(of: [.images, .livePhotos]))
		.fullScreenCover(isPresented: $showCaptureView, content: {
			CameraView(model:cameraDataModel, showCaptureView: $showCaptureView, viewModel: viewModel, sourceType: $sourceType)
		})
		.sheet(isPresented: $showChangePictureView, content: {
			ChangePictureView(wordCard: wordCard, showChangePictureView: $showChangePictureView)
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
		if selectedChangedPhoto != nil {
			selectedChangedPhoto!
				.resizable()
				.scaledToFill()
		} else {
			displayImageFromFile()
		}
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
			AsyncImage(url: URL(string: wordCard.iconURL)) { phase in
				if let image = phase.image {
					image
						.resizable()
						.scaledToFit()
						.padding()
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
}

/*#Preview {
 APictureCardView()
 }*/
