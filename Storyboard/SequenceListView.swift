//
//  SequenceListView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/9/29.
//

import SwiftUI
import CoreData

struct SequenceListView: View {
	@Environment(\.colorScheme) var colorScheme
	@EnvironmentObject var sequencer:Sequencer
	
	@State private var text = "Search"
	@State private var showStoryboard = false
	@State private var showAddNewSequence = false
	@State private var showEditSequence = false
	
	@Environment(\.managedObjectContext) private var viewContext
	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \Sentences.change_date, ascending: false)],
			animation: .default)
	private var sentences: FetchedResults<Sentences>
	
	@State private var tappedSentenceID:String = ""
	
	var body: some View {
		VStack(spacing:0) {
			HStack {
				Spacer()
				Button(action: {
					showAddNewSequence = true
				}, label: {
					Label(
						title: { Text("Search") },
						icon: { Image(systemName: "magnifyingglass") }
					)
					.labelStyle(.iconOnly)
					.font(.title2)
					.foregroundColor(Color("testColor2"))
				}).padding([.trailing],15)
					
				Button(action: {
					showAddNewSequence = true
				}, label: {
					Label(
						title: { Text("Add new") },
						icon: { Image(systemName: "plus.circle.fill") }
					)
					.labelStyle(.iconOnly)
					.font(.title2)
					.foregroundColor(Color("testColor2"))
				})
				/*TextEditor(text: $text)
				 .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))*/
			}
			.padding([.leading,.trailing,.top], 15)
			
			HStack {
				Spacer()
				Text("Sentences")
					.font(.largeTitle)
				Spacer()
			}
			if sentences.count > 0 {
				List {
					ForEach(sentences) { sentence in
						ListItemView(showEditSequence: $showEditSequence, showStoryboard: $showStoryboard, textLine: sentence.user_question ?? "", tappedSentenceID: $tappedSentenceID, sentenceID: sentence.id ?? "")
							/*.onTapGesture {
								do {
									let fetchWords = NSFetchRequest<Words>(entityName: "Words")
									fetchWords.predicate = NSPredicate(format: "sentenceID = %@", sentence.id ?? "")
									fetchWords.sortDescriptors = [NSSortDescriptor(keyPath: \Words.order, ascending: true)]
									let allWords = try viewContext.fetch(fetchWords)
									if allWords.count > 0 {
										sequencer.theStoryByUser = StoryByUser()
										sequencer.theStoryByUser.sentence = sentence.user_question ?? ""
										for wordItem in allWords {
											var addWordCard = WordCard()
											addWordCard.word = wordItem.word ?? ""
											addWordCard.cardOrder = Int(wordItem.order)
											print("\(String(describing: wordItem.word)) \(String(describing: wordItem.picID))")
											let fetchPictures = NSFetchRequest<Pictures>(entityName: "Pictures")
											fetchPictures.predicate = NSPredicate(format: "id = %@", wordItem.picID ?? "")
											fetchPictures.fetchLimit = 1
											let usePic = try viewContext.fetch(fetchPictures)
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
										showStoryboard = true
									} else {
										//error
										print("[debug] fetchWords with sentenceID\(String(describing: sentence.id)) has no item")
									}
								} catch {
									
								}
							}
							.onTapGesture {
								tappedSentenceID = sentence.id ?? ""
							}*/
					}/*.onDelete(perform: deleteASentence)*/
				}
				.modifier(myListStyle())
				//.listStyle(.plain)
				//.background(.green)
				//.scrollContentBackground(.hidden)
			}
			
			Spacer()
		}
		.background(Image(colorScheme == .light ? "vellum_sketchbook_paper" : "balck_canvas_bg4").resizable()
			.aspectRatio(contentMode: .fill)
			.edgesIgnoringSafeArea(.all))
		
		.fullScreenCover(isPresented: $showAddNewSequence, content: {
			NewSequenceView(showAddNewSequence: $showAddNewSequence, showStoryboard: $showStoryboard)
		})
		.fullScreenCover(isPresented: $showEditSequence, content: {
			EditSequenceView(showEditSequence: $showEditSequence, showStoryboard: $showStoryboard)
		})
		.fullScreenCover(isPresented: $showStoryboard, content: {
			ShowStoryView(showStoryboard: $showStoryboard)
		})
		.onAppear(perform: {
			//print("[deubg] pictureURL \(FileManager.picturesDirectoryURL.path())")
		})
	}
	
	struct myListStyle: ViewModifier {
		func body(content: Content) -> some View {
			if checkiOSversion() > 15 {
				content
					//.background(Color("testColor"))
					.scrollContentBackground(.hidden)
			} else {
				content
					.listStyle(.plain)
			}
		}
		
		private func checkiOSversion() -> Int {
			let osVersion = ProcessInfo.processInfo.operatingSystemVersion
			print("OS version major: \(osVersion.majorVersion)")
			print("OS version minor: \(osVersion.minorVersion)")
			print("OS version patch: \(osVersion.patchVersion)")
			return osVersion.majorVersion
		}
	}
	
	private func deleteASentence(offsets: IndexSet) {
		withAnimation {
			offsets.map { sentences[$0] }.forEach(viewContext.delete)
			do {
				try viewContext.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nsError = error as NSError
				fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
			}
		}
	}
}

#Preview {
	SequenceListView()
		.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
