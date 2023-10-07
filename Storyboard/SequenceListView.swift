//
//  SequenceListView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/9/29.
//

import SwiftUI

struct SequenceListView: View {
	@State private var text = "Search"
	@Binding var showStoryboard:Bool
	@State private var showAddNewSequence = false
	@Environment(\.colorScheme) var colorScheme
	
	var body: some View {
		VStack {
			HStack {
				Button(action: {
					showAddNewSequence = true
				}, label: {
					Label(
						title: { Text("Add new") },
						icon: { Image(systemName: "plus.app") }
					).labelStyle(.iconOnly).foregroundColor(Color("testColor2"))
				})
				TextEditor(text: $text)
					.clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
			}
			.frame(height: 35)
			.padding([.leading,.trailing,.top], 15)
			
			List {
				ListItemView(textLine: "Do you want to eat pasta or potato?")
					.onTapGesture {
						showStoryboard = true
					}
				ListItemView(textLine: "Will go to supermarket then go home.")
					.onTapGesture {
						showStoryboard = true
					}
			}
			.modifier(myListStyle())
			//.listStyle(.plain)
			//.background(.green)
			//.scrollContentBackground(.hidden)
		}
		.background(Image(colorScheme == .light ? "old_papge_bg11" : "balck_canvas_bg4").resizable()
			.aspectRatio(contentMode: .fill)
			.edgesIgnoringSafeArea(.all))
		//.background(Color("testColor"))
		.sheet(isPresented: $showAddNewSequence, content: {
			NewSequenceView(showAddNewSequence: $showAddNewSequence, showStoryboard: $showStoryboard)
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
}

#Preview {
	SequenceListView(showStoryboard: .constant(false))
}
