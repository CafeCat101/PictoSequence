//
//  FileManager.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/11/8.
//

import Foundation

public extension FileManager {
	static var documentoryDirecotryURL: URL {
	`default`.urls(for: .documentDirectory, in: .userDomainMask)[0]
	}
	
	/*static var pictureDirectoryURL: URL {
		`default`.urls(for: .documentDirectory, in: .userDomainMask)[0]
		documentoryDirecotryURL.append(path: "pictures",)
	}*/
	static var picturesDirectoryURL: URL? {
		//let picturesDirectoryURL = documentoryDirecotryURL.appendingPathComponent("Pictures")
		
		// Create the pictures directory string
		let picturesDirectoryString = documentoryDirecotryURL.path() + "pictures"

		// Create URL from pictures directory string
		let picturesDirectoryURL = URL(fileURLWithPath: picturesDirectoryString)
		
		// Create the folder if it doesn't exist
		if !FileManager.default.fileExists(atPath: picturesDirectoryURL.path) {
			do {
				try FileManager.default.createDirectory(at: picturesDirectoryURL, withIntermediateDirectories: true, attributes: nil)
			} catch {
				print(error.localizedDescription)
				return nil
			}
		}
		
		return picturesDirectoryURL
	}
}
