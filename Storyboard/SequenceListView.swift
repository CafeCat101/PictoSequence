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
	
	var body: some View {
		VStack {
			HStack {
				Spacer()
				Text("Sentences")
					.font(.title)
				Spacer()
			}
			.padding(15)
			
			HStack {
				Button(action: {
					showAddNewSequence = true
				}, label: {
					Label(
						title: { Text("Add new") },
						icon: { Image(systemName: "plus.circle.fill") }
					).labelStyle(.iconOnly).foregroundColor(Color("testColor2"))
						.font(.title2)
				})
				TextEditor(text: $text)
					.clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
			}
			.frame(height: 35)
			.padding([.leading,.trailing,.top], 15)
			
			if sentences.count > 0 {
				List {
					/*ListItemView(textLine: "Do you want to eat pasta or potato?")
						.onTapGesture {
							showStoryboard = true
						}
					ListItemView(textLine: "Will go to supermarket then go home.")
						.onTapGesture {
							showStoryboard = true
						}*/
					ForEach(sentences) { sentence in
						ListItemView(showEditSequence: $showEditSequence, textLine: sentence.user_question ?? "")
							.onTapGesture {
								do {
									let jsonData = sentence.result?.data(using: .utf8)!
									let sequenceDecoded = try JSONDecoder().decode([SequencerResponseSuccess].self, from: jsonData!)
									sequencer.currentStory.sentence = sentence.user_question ?? ""
									sequencer.currentStory.visualizedSequence = sequenceDecoded
									showStoryboard = true
								} catch {
									
								}
								
							}
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
