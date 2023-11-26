//
//  Sequencer.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/10/1.
//

import Foundation

class Sequencer: ObservableObject {
	var theStoryByAI:StoryByAI = StoryByAI()
	@Published var theStoryByUser:StoryByUser = StoryByUser()
	
	func generateNewSequence(sentence: String) async throws -> StoryByUser? {
		//Task {
		let now = Date()
		let gmtTimeZone = TimeZone(identifier: "UTC")
		var calendar = Calendar.current
		calendar.timeZone = gmtTimeZone!

		let hour = calendar.component(.hour, from: now)
		let day = calendar.component(.day, from: now)
		let verificationCode = hour+day+5
		print("[deubg] generateNewSequence, verificationCode \(verificationCode)")
		let postSequenceRequest = SequencerSendJsonObject(server_validation: verificationCode, user_question: sentence)
			do {
				let payload = try JSONEncoder().encode(postSequenceRequest)
				guard let url = URL(string: "https://icons.scorewind.com/completion-v2-api") else { fatalError("Missing URL") }
				var urlRequest = URLRequest(url: url)
				urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
				urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
				urlRequest.httpMethod = "POST"
				print("[debug] generateNewSequence, payload \(String(data: payload, encoding: .utf8)!)")
				let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: payload)
				
				guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data \(String(describing: (response as? HTTPURLResponse)?.statusCode))") }
				//print("[debug] generateNewSequence, data\(String(data: data, encoding: .utf8)!)")
				let successInfo = try JSONDecoder().decode([SequencerResponseSuccess].self, from: data)
				//print("[debug] generateNewSequence, Success: \(successInfo)")
				
				/*DispatchQueue.main.async {
				}*/
				//return StoryByAI(sentence: sentence,visualizedSequence: successInfo)
				print("[debug] Sequencer, generateNewSequence, sentence \(sentence)")
				self.theStoryByAI = StoryByAI(sentence: sentence,visualizedSequence: successInfo)
				return AIStoryToUserStory(AIstory: self.theStoryByAI)
			} catch  {
				print( error)
				print("[debug] generateNewSequence, error, failed to decode JSON")
				/*do {
					let errorType = try JSONDecoder().decode(SequencerResponseError.self, from: data)
					// Successfully decoded error
					print("[debug] generateNewSequence, Error \(errorType)")
				} catch {
					print("Failed to decode JSON")
				}*/
				return nil
			}
		//}
	}
	
	func AIStoryToUserStory(AIstory: StoryByAI) -> StoryByUser {
		var userStory = StoryByUser()
		print("[debug] Sequencer, AIStoryToUserStory, AIstory.sentence \(AIstory.sentence)")
		userStory.sentence = AIstory.sentence
		var wordOrderCount = 0
		for item in AIstory.visualizedSequence {
			for AIWord in item.words {
				wordOrderCount = wordOrderCount + 1
				var addWord = WordCard()
				addWord.word = AIWord.word
				addWord.cardOrder = wordOrderCount
				addWord.pictureType = .icon
				addWord.iconURL = AIWord.pictures[0].thumbnail_url
				addWord.pictureLocalPath = getLocalPictureURLPath(remoteURL: AIWord.pictures[0].thumbnail_url)
				userStory.visualizedSequence.append(addWord)
			}
		}
		return userStory
	}
	
	func getImageFileName(remoteURL: String) -> String {
		if let url = URL(string: remoteURL) {
				let fileName = url.lastPathComponent
				return fileName
		} else {
			return ""
		}
	}
	
	func getLocalPictureURLPath(remoteURL: String) -> String {
		if let url = URL(string: remoteURL) {
			var urlPathComponent = url.pathComponents
			urlPathComponent.remove(at: 0)
			return FileManager.storyboardPictureFolderName+"/"+urlPathComponent.joined(separator: "__")
		} else {
			return ""
		}
	}
}
