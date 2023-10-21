//
//  StoryboardApp.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/9/27.
//

import SwiftUI

@main
struct StoryboardApp: App {
	let persistenceController = PersistenceController.shared
	@StateObject var sequencer = Sequencer()
	
	var body: some Scene {
		WindowGroup {
			//ContentView()
			SequenceListView()
				.environmentObject(sequencer)
				.environment(\.managedObjectContext, persistenceController.container.viewContext)
		}
	}
}
