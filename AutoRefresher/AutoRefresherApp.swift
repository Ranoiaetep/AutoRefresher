//
//  AutoRefresherApp.swift
//  AutoRefresher
//
//  Created by Ranoiaetep on 1/19/21.
//

import SwiftUI

@main
struct AutoRefresherApp: App {
	@State var sidebar: Bool = true
    var body: some Scene {
        WindowGroup {
			ContentView()
		}
		.windowStyle(HiddenTitleBarWindowStyle())
		.windowToolbarStyle(UnifiedWindowToolbarStyle(showsTitle: true))
	}
}

func toggleSidebar() {
	NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}
