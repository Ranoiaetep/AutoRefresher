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
				.accentColor(Color(red: 1.0, green: 0.796, blue: 0.655))
		}
		.windowStyle(HiddenTitleBarWindowStyle())
//		.windowToolbarStyle(UnifiedWindowToolbarStyle(showsTitle: false))
	}
}
