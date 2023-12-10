//
//  PreviewStoryView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/10/6.
//

import SwiftUI

struct StoryView: View {
	@EnvironmentObject var sequencer:Sequencer
	@State private var gridHeight:CGFloat = 100
	
	@Binding var storyViewMode:StoryViewMode
	//var editMode = false
	
	let columns = [
		GridItem(.flexible()),
		//GridItem(.flexible()),
		//GridItem(.flexible())
	]
	
	var body: some View {
		VStack {
			/*HStack {
			 Spacer()
			 Text("preview your story")
			 Spacer()
			 }*/
			if sequencer.theStoryByUser.visualizedSequence.count > 0 {
				GeometryReader { reader1 in
					ScrollView(.vertical){
						VStack {
							HStack {
								Spacer()
								Grid {
									ForEach(sequencer.theStoryByUser.visualizedSequence) { item in
										GridRow {
											VStack {
												APictureCardView(wordCard: item, picWidth: reader1.size.width/2, picHeight: reader1.size.width/2, storyViewMode: $storyViewMode)
												//APictureView(word: item.word,urlStr: item.iconURL, picWidth: reader1.size.width/3, picHeight: reader1.size.width/3)
											}
											.padding([.top], (item.cardOrder == 1 && storyViewMode == .showSentence) ? 80 : 0)
											.padding([.bottom,.trailing],5)
										}
									}
									/*ForEach( sequencer.theStoryByUser.visualizedSequence , id: \.self) { item in
										GridRow {
											
											VStack {
												APictureView(word: item.word,urlStr: item.iconURL, picWidth: reader1.size.width/3, picHeight: reader1.size.width/3)
											}
											.padding([.bottom,.trailing],5)
											
						
										}
									}*/
								}
								Spacer()
							}
							.padding()
						}
						.onAppear(perform: {
							let picSize = reader1.size.width/2
							//let rowCount = CGFloat(allWords().count)
							let rowCount = CGFloat(sequencer.theStoryByUser.visualizedSequence.count)
							gridHeight = picSize*rowCount + 5*rowCount + 150
						})
						.frame(height: gridHeight)
					}
				}
				
				
				
			}
			
			
			
			Spacer()
		}
	}
	
	/*private func allWords() -> [AWordPic] {
		var words:[AWordPic] = []
		for part in sequencer.theStoryByAI.visualizedSequence {
			for wordData in part.words {
				words.append(AWordPic(word: wordData.word, picture: wordData.pictures[0].thumbnail_url))
			}
		}
		return words
	}*/
	
	struct AWordPic: Hashable {
		var word:String
		var picture:String
	}
}

/*#Preview {
	StoryView(sent)
}*/
