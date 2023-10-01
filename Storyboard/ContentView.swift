//
//  ContentView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/9/27.
//

import SwiftUI

struct ContentView: View {
	@State private var showStoryboard = false
	
	var body: some View {
		if showStoryboard == false {
			SequenceListView(showStoryboard: $showStoryboard)
		} else {
			ShowStoryView(showStoryboard: $showStoryboard)
		}
		
	}

}

#Preview {
	ContentView()
}
