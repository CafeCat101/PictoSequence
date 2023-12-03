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
				
							
							/*LazyVGrid(columns: columns) {
								ForEach( allWords() , id: \.self) { item in
									VStack {
										/*Text(item.word)
										 .font(.headline)
										 .padding()*/
										APictureView(word: item.word,urlStr: item.picture, picWidth: reader.size.width/3, picHeight: reader.size.width/3)
									}
									.background {
										RoundedRectangle(cornerRadius: 10)
											.foregroundColor(.green)
											.opacity(0.3)
									}
									.padding([.bottom,.trailing],5)
									/*VStack {
									 Text(item.words[0].word)
									 .font(.headline)
									 .padding()
									 }
									 .background {
									 RoundedRectangle(cornerRadius: 10)
									 .foregroundColor(.green)
									 .opacity(0.3)
									 }
									 .padding([.bottom,.trailing],5)*/
									/*VStack {
									 if index % 2 == 0 {
									 Text("story card \(index + 1)")
									 .font(.headline)
									 .padding()
									 .background(Color.green)
									 .cornerRadius(10)
									 } else {
									 EmptyView()
									 }
									 }.padding([.bottom,.trailing],5)*/
								}
							}
							.padding()*/
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
