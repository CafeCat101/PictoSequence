//
//  TestSheet.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/12/11.
//

import SwiftUI

struct TestSheet: View {
	@Binding var showTestSheet:Bool
	
	var body: some View {
		VStack {
			Text("hello, this is a test sheet.")
			Spacer()
			Button("Okay", action: {
				showTestSheet = false
			})
		}
		
	}
}
/*
#Preview {
	TestSheet()
}*/
