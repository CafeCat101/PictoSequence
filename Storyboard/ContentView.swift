//
//  ContentView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/9/27.
//

import SwiftUI

struct ContentView: View {
	@EnvironmentObject var sequencer:Sequencer
	@State private var showStoryboard = false
	
	var body: some View {
		if showStoryboard == false {
			SequenceListView()
				.onAppear(perform: {
					print(Date.now)
				})
		} else {
			ShowStoryView(showStoryboard: $showStoryboard)
		}
		
	}

}

#Preview {
	ContentView()
}
