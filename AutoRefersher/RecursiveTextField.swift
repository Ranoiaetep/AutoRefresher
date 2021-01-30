//
//  RecursiveTextField.swift
//  Auto Refersher
//
//  Created by Ranoiaetep on 1/22/21.
//

import SwiftUI

struct RecursiveTextField: View {
	@Binding var textList: [String]
	var index: Int = 0
	var placeholder: String = "Placeholder"
	@State private var skipped: Bool = false
	@State private var nextRecursion: AnyView?

	var body: some View {
		if !skipped {
			TextField(placeholder, text: $textList[index], onCommit: {
				if !textList[index].isEmpty {
					if !(textList.last?.isEmpty ?? false) {
						textList.append(String())
					}
					nextRecursion = AnyView(RecursiveTextField(textList: $textList, index: index + 1, placeholder: placeholder))
				} else if index != textList.count - 1 {
					skipped = true
				}
			})
		}
		nextRecursion
	}
}

struct RecursiveTextFieldPreviewContainer: View {
	@State var textList: [String] = [String(), String()] // For some reason I need 2 empty strings here, else it will crash

	var body: some View {
		VStack {
			RecursiveTextField(textList: $textList)
		}
	}
}

struct RecursiveTextField_Previews: PreviewProvider {

	static var previews: some View {
		RecursiveTextFieldPreviewContainer()
			.padding()
	}
}
