//
//  HeartRevsDefaults.swift
//  HeartRevs
//
//  Created by Andrew Ebling on 24/10/2020.
//  Copyright © 2020 Andrew Ebling. All rights reserved.
//

import Combine
import Foundation

class HeartRevsDefaults: ObservableObject {
    
    let defaultRestingHeartRate = Double(60)
    let defaultMaximumHeartRate = Double(150)
    
    enum Keys: String   {
        case restingHeartRate = "restingHeartRate"
        case maximumHeartRate = "maximumHeartRate"
    }
    
    static let shared = HeartRevsDefaults()
    
    init() {
        initializeDefaultValues()
    }
    
    private func initializeDefaultValues() {
        if restingHeartRate == 0 {
            restingHeartRate = defaultRestingHeartRate
        }
        
        if maximumHeartRate == 0 {
            maximumHeartRate = defaultMaximumHeartRate
        }
    }
    
    @Published var restingHeartRate: Double = UserDefaults.standard.double(forKey: Keys.restingHeartRate.rawValue) {
        didSet {
            UserDefaults.standard.setValue(restingHeartRate, forKey: Keys.restingHeartRate.rawValue)
        }
    }
    
    @Published var maximumHeartRate: Double = UserDefaults.standard.double(forKey: Keys.maximumHeartRate.rawValue) {
        didSet {
            UserDefaults.standard.setValue(maximumHeartRate, forKey: Keys.maximumHeartRate.rawValue)
        }
    }
}
