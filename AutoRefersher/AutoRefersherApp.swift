//
//  AutoRefersherApp.swift
//  AutoRefersher
//
//  Created by Ranoiaetep on 1/19/21.
//

import SwiftUI

@main
struct AutoRefersherApp: App {
	@State var sidebar: Bool = true
    var body: some Scene {
        WindowGroup {
			ContentView()
		}
		.windowStyle(HiddenTitleBarWindowStyle())
//		.windowToolbarStyle(UnifiedWindowToolbarStyle(showsTitle: false))
	}
}
