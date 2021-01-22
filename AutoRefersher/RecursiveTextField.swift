//
//  RecursiveTextField.swift
//  Auto Refersher
//
//  Created by Ranoiaetep on 1/22/21.
//

import SwiftUI

struct RecursiveTextField: View {
	@Binding var TextList: [String]
	var Index: Int = 0
	var Placeholder: String = "Placeholder"
	@State private var skipped: Bool = false
	@State private var NextRecursion: AnyView? = nil
	
	var body: some View {
		if !skipped {
			TextField(Placeholder, text: $TextList[Index], onCommit: {
				if !TextList[Index].isEmpty {
					TextList.append(String())
					NextRecursion = AnyView(RecursiveTextField(TextList: $TextList, Index: Index + 1, Placeholder: Placeholder))
				}
				else {
					skipped = true
				}
			})
		}
		NextRecursion
	}
}

struct RecursiveTextFieldPreviewContainer: View {
	@State var TextList: [String] = [String(), String()] // For some reason I need 2 empty strings here, else it will crash

	var body: some View {
		VStack {
			RecursiveTextField(TextList: $TextList)
		}
	}
}

struct RecursiveTextField_Previews: PreviewProvider {
	
	static var previews: some View {
		RecursiveTextFieldPreviewContainer()
			.padding()
	}
}
