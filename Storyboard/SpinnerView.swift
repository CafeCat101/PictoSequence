//
//  SpinnerView.swift
//  Storyboard
//
//  Created by Leonore Yardimli on 2023/10/6.
//

import SwiftUI

struct SpinnerView: View {
	@State private var isLoading = false
	//var frameSize: CGFloat
	var iconColor: Color
	var spinnerColor: Color
	var iconSystemImage: String
	//var spinnerGapColor: Color
	
	var body: some View {
		VStack(spacing:0) {
			Label("downloading", systemImage: "stop.circle")
				.labelStyle(.iconOnly)
				.foregroundColor(iconColor)
				.opacity(0)
				.overlay(alignment: .center ,content: {
					/*
					Label("circle", systemImage: "circle")
						.labelStyle(.iconOnly)
						.foregroundColor(spinnerGapColor)*/
					GeometryReader { reader in
						ZStack {
							Image(systemName: iconSystemImage)
								.resizable()
								.scaledToFit()
								.foregroundColor(iconColor)
						}.padding(6.5).frame(width:reader.size.width, height: reader.size.height)
						//.frame(width: reader.size.width*0.35, height: reader.size.height*0.35)
						//.offset(x: (reader.size.width - reader.size.width*0.35)/2, y: (reader.size.height - reader.size.height*0.35)/2)
					}
					
					
				})
		}
		.overlay(content: {
			/*Label("spinning", systemImage: "circle.dashed")
				.labelStyle(.iconOnly)
				.foregroundColor(.green)*/
			Circle()
				.trim(from: 0, to: 0.88)
				.stroke(spinnerColor, lineWidth: 2)
				/*.stroke(color, style: StrokeStyle(
					lineWidth: 2,
					lineCap: .round,
					lineJoin: .round,
					miterLimit: 0,
					dash: [4,5],
					dashPhase: 0
				))*/
				/*.background{
					Circle()
						.foregroundColor(Color("AppYellow"))
						.opacity(0)
				}*/
				.padding(2)
				//.frame(width: frameSize, height: frameSize)
				.rotationEffect(Angle(degrees: isLoading ? 360 : 0))
				.onAppear() {
					withAnimation(.default.repeatForever(autoreverses:false).speed(0.2)){
						self.isLoading = true
					}
				}
				.onDisappear(perform: {
					self.isLoading = false
				})
		})
		
	}
}

#Preview {
	SpinnerView(iconColor: .black, spinnerColor: .green, iconSystemImage: "stop.fill")
}
