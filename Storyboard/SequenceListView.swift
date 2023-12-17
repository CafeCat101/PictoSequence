//
//  SequenceListView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/9/29.
//

import SwiftUI
import CoreData
import SwiftUIX

struct SequenceListView: View {
	@Environment(\.colorScheme) var colorScheme
	@EnvironmentObject var sequencer:Sequencer
	@Environment(\.managedObjectContext) private var viewContext
	/*@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \Sentences.change_date, ascending: false)],
			animation: .default)
	private var sentences: FetchedResults<Sentences>*/
	
	@State private var sentences:[Sentences] = []
	@State private var searchText = ""
	@State private var isEditing = false
	@State private var showStoryboard = false
	@State private var showAddNewSequence = false
	@State private var showEditSequence = false
	@State private var tappedSentenceID:String = ""
	@State private var showSearchable = false
	@State private var searchableFocused = false
	
	var body: some View {
		VStack(spacing:0) {
			if showSearchable == false {
				HStack {
					Spacer()
					Button(action: {
						withAnimation {
							showSearchable = true
						}
						searchableFocused = true
					}, label: {
						Label(
							title: { Text("Search") },
							icon: { Image(systemName: "magnifyingglass") }
						)
						.labelStyle(.iconOnly)
						.font(.title)
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
						.font(.title)
						.foregroundColor(Color("testColor2"))
					})
				}
				.padding([.leading,.trailing,.top], 15)
				HStack {
					Spacer()
					Text("Sentences")
						.font(.largeTitle)
						.bold()
					Spacer()
				}
			} else {
				HStack {
					Spacer()
					Text("Sentences")
						.font(.title)
						.bold()
					Spacer()
				}
				HStack(spacing: 0) {
					SearchBar("Search",text: $searchText, isEditing: $isEditing, onCommit: {
						print("[debug] SequenceListView, search, onSubmit \(searchText)")
					})
					
						.showsCancelButton(false)
						/*.onCancel {
							print("Canceled!")
							withAnimation {
								showSearchable = false
							}
							searchText = ""
							//performSearch()
							updateSentenceList()
						}*/
						.focused($searchableFocused)
						.padding([.leading], 15)
						.onChange(of: searchText, perform: { newText in
							print("[debug] SequenceListView, search, onChange \(newText)")
							//performSearch()
							updateSentenceList()
						})
					
					Button("Cancel", action: {
						print("Canceled!")
						withAnimation {
							showSearchable = false
						}
						searchableFocused = false
						searchText = ""
						updateSentenceList()
						
					})
					.padding([.trailing], 15)
				}
				
			}
			
			if sentences.count > 0 {
				List {
					ForEach(sentences) { sentence in
						ListItemView(showEditSequence: $showEditSequence, showStoryboard: $showStoryboard, textLine: sentence.user_question ?? "", tappedSentenceID: $tappedSentenceID, sentenceID: sentence.id ?? "")
						if isLastSentence(sentenceID: sentence.id ?? "") {
							Spacer().frame(height: 100).listRowBackground(Color.clear).listRowSeparator(.hidden)
						}
					}/*.onDelete(perform: deleteASentence)*/
				}
				/*.simultaneousGesture(DragGesture().onChanged({ _ in
						// if keyboard is opened then hide it
					print("[debug] SequenceListView, list scrolling")
					searchableFocused = false
					print("[debug] SequenceListView, searchableFocused \(searchableFocused)")
				}))*/
				.scrollDismissesKeyboard(.immediately)
				.scrollContentBackground(.hidden)
				.listStyle(.plain)
				.padding([.top], 5)
			} else {
				HStack {
					Text("None Found").bold().foregroundColor(Color("StatusMessage"))
					Spacer()
				}.padding([.leading,.trailing], 15)
			}
			
			Spacer()
		}
		.onReceive(sequencer.updateSequenceListNow, perform: { updatedSentenceID in
			if updatedSentenceID.isEmpty == false {
				updateSentenceList()
			}
		})
		.ignoresSafeArea(edges: .bottom)
		.background(Image(colorScheme == .light ? "vellum_sketchbook_paper" : "balck_canvas_bg4").resizable()
			.aspectRatio(contentMode: .fill)
			.edgesIgnoringSafeArea(.all))
		.fullScreenCover(isPresented: $showAddNewSequence,content: {
			NewSequenceView(showAddNewSequence: $showAddNewSequence, showStoryboard: $showStoryboard, tappedSentenceID: $tappedSentenceID)
		})
		.fullScreenCover(isPresented: $showEditSequence, content: {
			EditSequenceView(showEditSequence: $showEditSequence, showStoryboard: $showStoryboard, tappedSentenceID: $tappedSentenceID)
		})
		.fullScreenCover(isPresented: $showStoryboard, content: {
			ShowStoryView(showStoryboard: $showStoryboard)
		})
		.onAppear(perform: {
			print("[debug] SequenceListView, onAppear, searchText:\(searchText)")
			//print("[deubg] pictureURL \(FileManager.picturesDirectoryURL.path())")
			updateSentenceList()
		})
	}
	
	struct myListStyle: ViewModifier {
		func body(content: Content) -> some View {
			if checkiOSversion() > 15 {
				content
					//.background(Color("testColor"))
					.scrollContentBackground(.hidden)
					.listStyle(.plain)
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
	
	/*private func performSearch() {
		let predicate:NSPredicate?
		if searchText.isEmpty == false {
			predicate = NSPredicate(format: "user_question CONTAINS[c] %@", searchText)
			//let sentencePredicate = NSPredicate(format: "user_question CONTAINS[d] %@", searchText)
			//predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [sentencePredicate])
		} else {
			predicate = nil
		}
		sentences.nsPredicate = predicate
	}*/
	
	private func updateSentenceList() {
		do {
			let fetchRequest = NSFetchRequest<Sentences>(entityName: "Sentences")
			if searchText.isEmpty == false {
				fetchRequest.predicate = NSPredicate(format: "user_question CONTAINS[c] %@", searchText)
			}
			fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Sentences.change_date, ascending: false)]
			sentences = try viewContext.fetch(fetchRequest)
			print("[debug] SequenceListView, updateSentenceList(), sentenceCount \(sentences.count), searchText:\(searchText)")
		} catch {
			
		}
	}
	
	private func isLastSentence(sentenceID:String) -> Bool {
		if sentenceID == sentences.last?.id {
			return true
		} else {
			return false
		}
	}
}

#Preview {
	SequenceListView()
		.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
