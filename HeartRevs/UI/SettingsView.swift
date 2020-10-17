//
//  SettingsView.swift
//  HeartRevsSwiftUI
//
//  Created by Andrew Ebling on 15/10/2020.
//  Copyright © 2020 Andrew Ebling. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var resting = 60
    @State private var maximum = 190
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Heart Rates")) {
                    Stepper(value: $resting, in: 10...1000) {
                        Text("Resting: \(resting) BPM")
                    }
                    Stepper(value: $maximum, in: 100...250) {
                        Text("Maximum: \(maximum) BPM")
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
