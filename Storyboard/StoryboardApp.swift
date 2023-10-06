//
//  StoryboardApp.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/9/27.
//

import SwiftUI

@main
struct StoryboardApp: App {
	@StateObject var sequencer = Sequencer()
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.onAppear(perform: {
					sequencer.setupTrainingModel()
				})
				.environmentObject(sequencer)
		}
	}
}
