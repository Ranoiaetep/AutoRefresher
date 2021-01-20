//
//  ContentView.swift
//  AutoRefersher
//
//  Created by Ranoiaetep on 1/19/21.
//

import SwiftUI

struct ContentView: View {
	@Environment(\.openURL) var openURL
	
	let doubleFormatter = NumberFormatter()
	let dateFormatter = DateComponentsFormatter()

	@State private var addressList: [String] = [""]
	@State private var originalField: [String] = [""]
	@State private var addressCount: Int = 1
	@State private var visitTimes: Double = 50
	@State private var remainingTimes: Double = 50
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
					ForEach((0..<addressCount), id: \.self) { index in
						VStack {
							TextField("https://www.apple.com", text: $addressList[index], onCommit: {
								if !addressList[index].isEmpty &&
									addressList[index] != originalField[index] &&
									!(addressList.last?.isEmpty ?? true) {
										originalField[index] = addressList[index]
										addressList.append("")
										originalField.append("")
										addressCount += 1
									}
							})
							.frame(minWidth: 200)
						}
					}
				}
				Text("x")
				TextField("0", value: $visitTimes, formatter: NumberFormatter())
					.frame(width: 50)
				
				Group{
					if !started || remainingTimes == 0 {
						Button("Start", action: {
							firstRun = false
							started = true
							remainingTimes = visitTimes
							if remainingTimes > 0 {
								for address in addressList{
									guard let url: URL = URL(string: address) else {
										continue
									}
									openURL(url)
								}
								remainingTimes -= 1
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
				.frame(width: 45)
			}
			HStack {
				Toggle(isOn: $optionMenu) {
					Label("Advance", systemImage: "gearshape.2.fill")
				}
				.toggleStyle(SwitchToggleStyle())
				Spacer()
				HStack {
					if started {
						ProgressView(value: (visitTimes - remainingTimes) / visitTimes)
							.onReceive(timer, perform: { _ in
								if remainingTimes > 0 {
									for address in addressList{
										guard let url: URL = URL(string: address) else {
											continue
										}
										openURL(url)
									}
									remainingTimes -= 1
								}
							})
						let time = remainingTimes * interval
						Group {
							if time > 0 {
								Text(dateFormatter.string(from: time) ?? "Job done!")
									.frame(alignment: .leading)
							}
							else {
								Label("Job done!", systemImage: "checkmark.circle.fill")
									.frame(alignment: .center)
									.foregroundColor(.accentColor)
							}
						}
						.frame(width: 150)
					}
					else {
						if remainingTimes == visitTimes {
							ProgressView(value: 0.0)
						}
						else {
							ProgressView(value: (visitTimes - remainingTimes) / visitTimes)
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
		.padding()
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
		ContentView()
    }
}
