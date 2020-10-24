[![Build status](https://build.appcenter.ms/v0.1/apps/fbccdaba-9bd6-4800-999d-6de5d26615f1/branches/master/badge)](https://appcenter.ms)

# HeartRevs #

## Introduction ##

HeartRevs is a simple work-in-progress prototype project which uses the CoreBluetooth API to connect to a heart rate monitor (HRM) and display the current reading, in Beats Per Minute. It was originally inspired by the [CoreBluetooth tutorial by Jaward Ahmad](https://www.raywenderlich.com/231-core-bluetooth-tutorial-for-ios-heart-rate-monitor), but avoids mixing Bluetooth/UI code for better Separation of Concerns (AKA Massive View Controller code smell), aims for cleaner code and aims to go further in implementing most of [Apple's Bluetooth Best Practices](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/EnergyGuide-iOS/BluetoothBestPractices.html) to maximise energy efficiency and generally be a good iOS citizen.

When run on a real device it automatically scans and connects to the first heart rate monitor it finds and was built and tested using the Wahoo TICKR HRM. When run on the iOS Simulator, it uses the excellent [NordicSemi IOS-CoreBluetooth-Mock library](https://github.com/NordicSemiconductor/IOS-CoreBluetooth-Mock) to mock out CoreBlueetoth and simulate a heart rate monitor, with a static BPM of 62.

The app supports iOS Dark Mode out of the box, through making use of built-in platform support.

## How it Works ##

In Bluetooth terminology, the device acts as a Central and the HRM acts as a Peripheral, similar in concept to a client-server model.

The connection and update process works as follows:

1. Scan for peripherals matching the Bluetooth HRM service ID
2. On discovering an HRM
    1. Stop scanning (scanning is expensive from an energy perspective)
    2. Connect to the peripheral
3. On connection to the peripheral, discover the services it supports
4. Iterate over each Service and discover Characteristics, looking for the HRM Characteristic ID
5. Iterate over discovered Characteristics and subscribe to notifications on the first HRM Characteristic found. This is [more energy efficient](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/EnergyGuide-iOS/BluetoothBestPractices.html)  than polling for updated values.
6. Wait for updated values to be received
7. Update the UI

The app aims to be a good citizen and relinquish all Bluetooth resources on going into the background and re-connect on coming back to the foreground.

## Further Work ##

* Improved error recovery - plenty of scope here!
* Improve the UI/UX:
  * Show a `UIActivityIndicator` while connecting to the Bluetooth peripheral, rather than ---.
  * Connect to the HRM with the highest RSSI (signal strength), rather than the first one discovered.
* Add an `XCTest` targe and use the CoreBluetooth Mock library to comprehensively test:
  * Error conditions
  * Recovery from error conditions (e.g. HRM going out of range and coming back into range)
  * The two-byte BPM format which some HRMs support (currently untested)
* Add UI tests using `XCUITest`.
* Make `HRMReader.swift` generic, so it can be used for any type of Bluetooth peripheral.

## Architecture ##

* Although a simple demo/prototype, the app aims to:
  * separate view code from the hardware interface
  * keep the view controller as small as possible
* The architecture could be further improved by extracting/separating the business logic from `HRMReader.swift` and re-implement as a state machine.

## Requirements ##

* Xcode 12
* iOS 14
* Apple iOS Developer Programme membership (for running on a real device)
* Bluetooth LE Heart Rate Monitor (when running on a real device)
