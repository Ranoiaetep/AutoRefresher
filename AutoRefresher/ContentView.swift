//
//  ContentView.swift
//  AutoRefresher
//
//  Created by Ranoiaetep on 1/26/21.
//

import SwiftUI
import AppKit
import UserNotifications
import RecursiveTextField

struct ContentView: View {
	let doubleFormatter = NumberFormatter()
	let dateFormatter = DateComponentsFormatter()

	let center = UNUserNotificationCenter.current()
	let notification = UNMutableNotificationContent()
	let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.3, repeats: false)

	@State var addressList: [String] = [String()]
	@State private var visitTimes: Double = 100
	@State private var remainingTimes: Double = 100
	@State private var optionMenu: Bool = false
	@State private var interval: Double = 1.8
	@State private var started: Bool = false
	@State private var firstRun: Bool = true
	@State private var notificationOn: Bool = true

	init() {
		center.requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { _, _ in}
		
		center.getNotificationSettings { settings in
			guard (settings.authorizationStatus == .authorized) ||
				  (settings.authorizationStatus == .provisional) else { return }

			if settings.alertSetting == .enabled {
				// Schedule an alert-only notification.
			} else {
				// Schedule a notification with a badge and sound.
			}
		}
			
//		notification.title = "Auto Refresher"
		notification.body = "􀁣 Job done!"
		
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
		VStack {
			HStack {
				VStack {
					RecursiveTextField(textList: $addressList, placeholder: "https://github.com/Ranoiaetep/AutoRefresher")
				}
				Text("x")
				TextField("0", value: $visitTimes, formatter: NumberFormatter(), onCommit: {
					remainingTimes = visitTimes
				})
					.frame(width: 50)
				
				Group {
					if !started || remainingTimes == 0 {
						Button("Start", action: {
							if !isAllEmptyString(addressList) {
								firstRun = false
								started = true
								remainingTimes = visitTimes
								if remainingTimes > 0 {
									for address in addressList {
										guard let url: URL = URL(string: address) else {
											continue
										}
										NSWorkspace.shared.open(url)
									}
									remainingTimes -= 1
								}
							}
						})
					} else {
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
						if remainingTimes > 0 && !isAllEmptyString(addressList) {
							for address in addressList {
								guard let url: URL = URL(string: address) else {
									continue
								}
								NSWorkspace.shared.open(url)
							}
							remainingTimes -= 1
							if remainingTimes == 0 && notificationOn {
								let request = UNNotificationRequest(identifier: "request", content: notification, trigger: trigger)
								center.add(request) { _ in}
							}
						}
					}
				})
			}
			.frame(minWidth: 450)
			HStack {
				Toggle(isOn: $optionMenu) {
                    if #available(OSX 11.0, *) {
                        Label("Advance", systemImage: "gearshape.2.fill")
                    } else {
                        HStack {
                            Text("􀥏 Advance")
                        }
                    }
				}
				.toggleStyle(SwitchToggleStyle())
				HStack {
                    if #available(OSX 11.0, *) {
                        ProgressView(value: (visitTimes - remainingTimes) / visitTimes)
                    }
                    else {
                        ProgressBarUI(visitTimes: $visitTimes, remainingTimes: $remainingTimes)
                            .frame(height: 5)
                    }
					if started {
						let time = remainingTimes * interval
						Group {
							if time > 0 {
								Text(dateFormatter.string(from: time) ?? "Job done!")
									.frame(alignment: .leading)
							}
							else {
                                Group {
                                    if #available(OSX 11.0, *) {
                                        Label("Job done!", systemImage: "checkmark.circle.fill")
                                    } else {
                                        HStack {
                                            Text("􀁣 Job done!")
                                        }
                                    }
                                }
									.frame(alignment: .center)
									.foregroundColor(.red	)
							}
						}
						.frame(width: 150)
					}
					else {
						Group {
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
				OptionMenu(interval: $interval, notification: $notificationOn, doubleFormatter: doubleFormatter)
			}
		}
		.padding()
	}
}

struct OptionMenu: View {
	@Binding var interval: Double
	@Binding var notification: Bool
	var doubleFormatter: NumberFormatter
	
	var body: some View {
		HStack {
			Spacer()
			GroupBox {
				HStack {
					Spacer()
					Text("Interval:")
					Stepper(value: $interval, step: 0.2) {
						TextField("", value: $interval, formatter: doubleFormatter)
							.frame(width: 40)
					}
					Spacer()
					Toggle(isOn: $notification) {
						Text("Notification:")
					}
					.toggleStyle(SwitchToggleStyle())
					Spacer()
				}
				.frame(minWidth: 300, idealWidth: 400, maxWidth: 400)
			}
			Spacer()
		}
	}
}

@available(OSX 11.0, *)
struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			ContentView()
			OptionMenu(interval: .constant(2.5), notification: .constant(true), doubleFormatter: NumberFormatter())
		}
		.padding(5)
	}
}

private func isAllEmptyString(_ stringList: [String]) -> Bool {
    for string in stringList where !string.isEmpty {
        return false
	}
	return true
}

private func nonEmptyCount(_ stringList: [String]) -> Int {
	var count = 0
	for string in  stringList where !string.isEmpty {
        count += 1
	}
	if !stringList.last!.isEmpty {
		count -= 1
	}
	return count
}

struct ProgressBarUI: View {
	@Binding var visitTimes: Double
	@Binding var remainingTimes: Double

	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .leading) {
				RoundedRectangle(cornerRadius: 45.0)
                    .frame(width: geometry.size.width,
                           height: geometry.size.height)
					.opacity(0.3)
					.foregroundColor(Color(NSColor.systemGray))
					.border(Color.gray.opacity(0.1), width: 1.0)
				RoundedRectangle(cornerRadius: 45.0)
                    .frame(
                        width: min(
                            CGFloat((self.visitTimes - self.remainingTimes)
								/ self.visitTimes + 0.02) * geometry.size.width,
                            geometry.size.width),
                        height: geometry.size.height)
				.foregroundColor(Color(NSColor.systemBlue))
				.animation(.easeInOut)
			}
		}
	}
}
