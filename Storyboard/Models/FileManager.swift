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
	
	static var pictureDirectoryURL: URL {
		documentoryDirecotryURL.appending(path: "pictures")
	}
}
