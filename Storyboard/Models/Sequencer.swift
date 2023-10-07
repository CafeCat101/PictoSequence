//
//  Sequencer.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/10/1.
//

import Foundation

class Sequencer: ObservableObject {
	var ourTrainingModel: TrainingModel =  TrainingModel()
	let trainingModelURL = URL(fileURLWithPath: "training-model", relativeTo: Bundle.main.bundleURL).appendingPathExtension("json")
	var currentStory:Story = Story()
	
	func generateNewSequence(sentence: String) async throws -> Story? {
		//Task {
			var postSequenceRequest = SequencerSendJsonObject()
			postSequenceRequest.model = ourTrainingModel.model
			postSequenceRequest.system = ourTrainingModel.system
			postSequenceRequest.q1 = ourTrainingModel.training[0].question
			let a1 = try JSONEncoder().encode(ourTrainingModel.training[0].answer)
			postSequenceRequest.a1 = String(data: a1, encoding: .utf8)!
			postSequenceRequest.q2 = ourTrainingModel.training[1].question
			let a2 = try JSONEncoder().encode(ourTrainingModel.training[1].answer)
			postSequenceRequest.a2 = String(data: a2, encoding: .utf8)!
			postSequenceRequest.q3 = ourTrainingModel.training[2].question
			let a3 = try JSONEncoder().encode(ourTrainingModel.training[2].answer)
			postSequenceRequest.a3 = String(data: a3, encoding: .utf8)!
			postSequenceRequest.q4 = ourTrainingModel.training[3].question
			let a4 = try JSONEncoder().encode(ourTrainingModel.training[3].answer)
			postSequenceRequest.a4 = String(data: a4, encoding: .utf8)!
			postSequenceRequest.q5 = ourTrainingModel.training[4].question
			let a5 = try JSONEncoder().encode(ourTrainingModel.training[4].answer)
			postSequenceRequest.a5 = String(data: a5, encoding: .utf8)!
			postSequenceRequest.user_question = sentence
			
			do {
				let payload = try JSONEncoder().encode(postSequenceRequest)
				guard let url = URL(string: "https://icons.scorewind.com/completion-api") else { fatalError("Missing URL") }
				var urlRequest = URLRequest(url: url)
				urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
				urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
				urlRequest.httpMethod = "POST"
				print("[debug] generateNewSequence, payload \(payload)")
				let (data, response) = try await URLSession.shared.upload(for: urlRequest, from: payload)
				
				guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data \(String(describing: (response as? HTTPURLResponse)?.statusCode))") }

				let successInfo = try JSONDecoder().decode([SequencerResponseSuccess].self, from: data)
				
				print(String(data: data, encoding: .utf8) ?? "default value")
				print("[debug] generateNewSequence, Success: \(successInfo)")
				
				DispatchQueue.main.async {
				}
				return Story(sequence: successInfo)
			} catch  {
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
	
	func setupTrainingModel() {
		do {
			if let jsonData = try String(contentsOfFile: trainingModelURL.path).data(using: .utf8) {
				ourTrainingModel = try JSONDecoder().decode(TrainingModel.self, from: jsonData)
				print("[debug]setupTrainingModel(): decoded")
				//print("[debug]setupTrainingModel() \(ourTrainingModel)")
			}
		} catch {
			print("[debug]setupTrainingModel()\(error)")
		}
	}
}
