//
//  ContentView.swift
//  Auto Refresher-10.15
//
//  Created by Peter Cong on 1/24/21.
//

import SwiftUI
import AppKit

struct ContentView: View {
	let doubleFormatter = NumberFormatter()
	let dateFormatter = DateComponentsFormatter()
	
	@State var addressList: [String] = [String()]
	@State private var visitTimes: Double = 100
	@State private var remainingTimes: Double = 100
	@State private var optionMenu: Bool = false
	@State private var interval: Double = 1.8
	@State private var started: Bool = false
	@State private var firstRun: Bool = true
	
	init() {
		self.started = started
		doubleFormatter.usesSignificantDigits = true
		doubleFormatter.maximumFractionDigits = 2
		dateFormatter.unitsStyle = .short
		dateFormatter.collapsesLargestUnit = true
		dateFormatter.maximumUnitCount = 1
		dateFormatter.includesApproximationPhrase = true
		dateFormatter.includesTimeRemainingPhrase = true
		dateFormatter.allowedUnits = [.minute, .second, .hour]
	}
	
	var body: some View {
		let timer = Timer.publish(every: interval, on: .main, in: .common).autoconnect()
		VStack{
			HStack {
				VStack {
					RecursiveTextField(TextList: $addressList, Placeholder: "https://github.com/Ranoiaetep/AutoRefresher")
				}
				Text("x")
				TextField("0", value: $visitTimes, formatter: NumberFormatter(), onCommit: {
					remainingTimes = visitTimes
				})
					.frame(width: 50)
				Group{
					if !started || remainingTimes == 0 {
						Button("Start", action: {
							if !AllEmptyString(addressList) {
								firstRun = false
								started = true
								remainingTimes = visitTimes
								if remainingTimes > 0 {
									for address in addressList{
										guard let url: URL = URL(string: address) else {
											continue
										}
										NSWorkspace.shared.open(url)
									}
									remainingTimes -= 1
								}
							}
						})
					}
					else {
						Button(action: {
							started = false
						}, label: {
							Text("Stop")
						})
					}
				}
				.frame(width: 50)
				.onReceive(timer, perform: {_ in
					if started {
						if remainingTimes > 0 && !AllEmptyString(addressList)  {
							for address in addressList{
								guard let url: URL = URL(string: address) else {
									continue
								}
								NSWorkspace.shared.open(url)
							}
							remainingTimes -= 1
						}
					}
				})
			}
			HStack {
				Toggle(isOn: $optionMenu) {
					HStack {
						Text("􀥏 Advance")
					}
				}
				.toggleStyle(SwitchToggleStyle())
				HStack {
					if started {
						ProgressBar(visitTimes: $visitTimes, remainingTimes: $remainingTimes)
							.frame(height: 5)
						let time = remainingTimes * interval
						Group {
							if time > 0 {
								Text(dateFormatter.string(from: time) ?? "Job done!")
									.frame(alignment: .leading)
							}
							else {
								HStack {
									Text("􀁣 Job done!")
								}
									.frame(alignment: .center)
									.foregroundColor(.red	)
							}
						}
						.frame(width: 150)
					}
					else {
						if remainingTimes == visitTimes {
							ProgressBar(visitTimes: $visitTimes, remainingTimes: $remainingTimes)
								.frame(height: 5)
						}
						else {
							ProgressBar(visitTimes: $visitTimes, remainingTimes: $remainingTimes)
								.frame(height: 5)
						}
						Group{
							if remainingTimes > 0 && !firstRun {
								Text(String(format: "%.0f x remaining", remainingTimes))
									.frame(alignment: .center)
							}
							else {
								Spacer()
							}
						}
						.frame(width: 150)
					}
				}
			}
			if optionMenu {
				OptionMenu(interval: interval, doubleFormatter: doubleFormatter)
			}
		}
		.padding()
	}
}

struct OptionMenu: View {
	@State var interval: Double
	var doubleFormatter: NumberFormatter
	
	var body: some View {
		HStack {
			Spacer()
			GroupBox() {
				HStack {
					Text("Interval:")
					Stepper(value: $interval, step: 0.2)
					{
						TextField("", value: $interval, formatter: doubleFormatter)
							.frame(width: 40)
					}
				}
				.frame(minWidth: 300, idealWidth: 400, maxWidth: 400)
			}
			Spacer()
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			ContentView()
			OptionMenu(interval: 2.5, doubleFormatter: NumberFormatter())
		}
		.padding(5)
	}
}


fileprivate func AllEmptyString(_ stringList: [String]) -> Bool {
	for string in stringList {
		if !string.isEmpty {
			return false
		}
	}
	return true
}


fileprivate func NonEmptyCount(_ stringList: [String]) -> Int {
	var count = 0
	for string in  stringList {
		if !string.isEmpty {
			count += 1
		}
	}
	if !stringList.last!.isEmpty {
		count -= 1
	}
	return count
}

struct ProgressBar: View {
	@Binding var visitTimes: Double
	@Binding var remainingTimes: Double

	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .leading) {
				RoundedRectangle(cornerRadius: 45.0).frame(width: geometry.size.width , height: geometry.size.height)
					.opacity(0.3)
					.foregroundColor(Color(NSColor.systemGray))
					.border(Color.gray.opacity(0.1), width: 1.0)
				RoundedRectangle(cornerRadius: 45.0).frame(width: min(CGFloat((self.visitTimes - self.remainingTimes) / self.visitTimes + 0.02) * geometry.size.width, geometry.size.width), height: geometry.size.height)
				.foregroundColor(Color(NSColor.systemBlue))
				.animation(.easeInOut)
			}
		}
	}
}
