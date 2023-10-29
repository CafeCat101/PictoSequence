//
//  Sequencer.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/10/1.
//

import Foundation

class Sequencer: ObservableObject {
	var theStoryByAI:StoryByAI = StoryByAI()
	
	func generateNewSequence(sentence: String) async throws -> StoryByAI? {
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
				return StoryByAI(sentence: sentence,visualizedSequence: successInfo)
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
	

}
