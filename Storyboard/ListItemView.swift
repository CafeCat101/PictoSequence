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
					let sentence = try managedContext.fetch(fetchRequest).first
					let jsonData =  sentence!.result?.data(using: .utf8)!
					let sequenceDecoded = try JSONDecoder().decode([SequencerResponseSuccess].self, from: jsonData!)
					sequencer.theStoryByAI.sentence = sentence!.user_question ?? ""
					sequencer.theStoryByAI.visualizedSequence = sequenceDecoded
					showEditSequence = true
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
						for sentence in sentences {
							managedContext.delete(sentence)
						}
						try managedContext.save()
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
}

#Preview {
	ListItemView(showEditSequence: .constant(false))
}
