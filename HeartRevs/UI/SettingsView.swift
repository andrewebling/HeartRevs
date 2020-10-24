//
//  SettingsView.swift
//  HeartRevsSwiftUI
//
//  Created by Andrew Ebling on 15/10/2020.
//  Copyright © 2020 Andrew Ebling. All rights reserved.
//

import SwiftUI
import Combine

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var settings = HeartRevsDefaults.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Heart Rates")) {
                    Stepper(value: $settings.restingHeartRate, in: 10...120) {
                        Text("Resting: \(settings.restingHeartRate, specifier: "%.0f") BPM")
                    }
                    Stepper(value: $settings.maximumHeartRate, in: 100...250) {
                        Text("Maximum: \(settings.maximumHeartRate, specifier: "%.0f") BPM")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
