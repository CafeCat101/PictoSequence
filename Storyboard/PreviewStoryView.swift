//
//  PreviewStoryView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/10/6.
//

import SwiftUI

struct PreviewStoryView: View {
	var story:Story
    var body: some View {
        Text("Preview your story.")
    }
}

#Preview {
	PreviewStoryView(story: Story())
}
