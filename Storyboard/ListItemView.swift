//
//  ListItemView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/9/27.
//

import SwiftUI

struct ListItemView: View {
	var textLine:String = "Sequence"
	var body: some View {
		VStack {
			Text("\(textLine)")
		}
		.swipeActions {
			Button("Edit") {
				print("edit!")
			}
			.tint(.green)
			
			Button("Delete") {
				print("delete!")
			}
			.tint(.red)
		}
		.foregroundColor(Color("testColor2"))
		.listRowBackground(Color.clear)
	}
}

#Preview {
	ListItemView()
}
