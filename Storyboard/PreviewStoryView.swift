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
	@Environment(\.managedObjectContext) private var viewContext
	let fetchRequest = NSFetchRequest<Sentences>(entityName: "Sentences")
	
	//var previewSentence:String = ""
	@Binding var showSequenceActionView:Bool
	@Binding var showStoryboard:Bool
	
	@State private var showSaveErrorAlert = false
	@State private var saveError = ""

	var body: some View {
		VStack {
			Text(sequencer.theStoryByAI.sentence)
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
			let existedSentences = try viewContext.fetch(fetchRequest)
			if existedSentences.isEmpty {
				let newItem = Sentences(context: viewContext)
				newItem.user_question = sequencer.theStoryByAI.sentence
				let seguenceJson = try JSONEncoder().encode(sequencer.theStoryByAI.visualizedSequence)
				newItem.result = String(data: seguenceJson, encoding: .utf8)!
				newItem.change_date = Date()
				try viewContext.save()
				
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
