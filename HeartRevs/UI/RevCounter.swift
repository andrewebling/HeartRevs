//
//  RevCounter.swift
//  HeartRevs
//
//  Created by Andrew Ebling on 17/10/2020.
//  Copyright © 2020 Andrew Ebling. All rights reserved.
//

import SwiftUI

struct RevCounter: View {
    
    struct HeartRateZone {
        let minBPM: Double
        let maxBPM: Double
        let color: Color
        let blur: CGFloat
    }
    
    @Binding var bpm: Double
    
    private let hrZones = [
        HeartRateZone(minBPM: 0, maxBPM: 140, color: .green, blur: 0),
        HeartRateZone(minBPM: 140, maxBPM: 175, color: .yellow, blur: 3),
        HeartRateZone(minBPM: 175, maxBPM: 190, color: .red, blur: 8)
    ]
    
    var body: some View {
        ZStack {
            RevCounterOutline()
                .foregroundColor(Color(UIColor.secondarySystemFill))
            
            // provides staged glow, drawn underneath main bar
            RevCounterBar(bpm: bpm)
                .foregroundColor(colorFor(bpm: bpm))
                .brightness(0.2)
                .blur(radius: blurFor(bpm: bpm))
            
            RevCounterBar(bpm: bpm)
                .foregroundColor(colorFor(bpm: bpm))
        }
    }
    
    struct RevCounterBar: Shape {
        
        var bpm: Double
        
        var animatableData: Double {
            get { bpm }
            set { self.bpm = newValue }
        }
        
        func path(in rect: CGRect) -> Path {
            var p = Path()
            p.addArc(center: CGPoint(x: rect.size.width/2, y: (rect.size.height/2)-12), radius: 150, startAngle: .degrees(120), endAngle: .degrees(120 + (300 * ((bpm - 60) / (190 - 60)))), clockwise: false)

            return p.strokedPath(.init(lineWidth: 20, lineCap: .round))
        }
    }

    struct RevCounterOutline: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            p.addArc(center: CGPoint(x: rect.size.width/2, y: (rect.size.height/2)-12), radius: 150, startAngle: .degrees(120), endAngle: .degrees(60), clockwise: false)

            return p.strokedPath(.init(lineWidth: 20, lineCap: .round))
        }
    }
    
    private func colorFor(bpm: Double) -> Color {
        
        var color: Color = .black
        hrZones.forEach { (zone) in
            if bpm <= zone.maxBPM && bpm >= zone.minBPM {
                color = zone.color
            }
        }
        return color
    }
    
    private func blurFor(bpm: Double) -> CGFloat {
        var blur: CGFloat = 0
        
        hrZones.forEach { (zone) in
            if bpm <= zone.maxBPM && bpm >= zone.minBPM {
                blur = zone.blur
            }
        }
        
        return blur
    }
}
