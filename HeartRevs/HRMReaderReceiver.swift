//
//  HRMReaderReceiver.swift
//  HeartRevs
//
//  Created by Andrew Ebling on 17/10/2020.
//  Copyright © 2020 Andrew Ebling. All rights reserved.
//

import Foundation

// Simple wrapper to bridge received data into SwiftUI
class HRMReaderReceiver: ObservableObject, HRMReaderDelegate {
    
    @Published var bpm: Double = 62
    @Published var error: String?
    
    func didUpdate(bpm: Int) {
        self.bpm = Double(bpm)
    }
    
    func didEncounter(error: String) {
        self.error = error
    }
}
