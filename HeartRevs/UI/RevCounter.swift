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
        let minPercent: Double
        let maxPercent: Double
        let color: Color
        let blur: CGFloat
    }
    
    @Binding var bpm: Double
    @Binding var minimum: Double
    @Binding var maximum: Double
    
    private let hrZones = [
        HeartRateZone(minPercent: 0, maxPercent: 60, color: .green, blur: 0),
        HeartRateZone(minPercent: 60, maxPercent: 75, color: .yellow, blur: 3),
        HeartRateZone(minPercent: 75, maxPercent: 100, color: .red, blur: 8)
    ]
    
    var body: some View {
        ZStack {
            RevCounterOutline()
                .foregroundColor(Color(UIColor.secondarySystemFill))
            
            // provides staged glow, drawn underneath main bar
            RevCounterBar(bpm: bpm, minimum: minimum, maximum: maximum)
                .foregroundColor(colorFor(bpm: bpm))
                .brightness(0.2)
                .blur(radius: blurFor(bpm: bpm))
            
            RevCounterBar(bpm: bpm, minimum: minimum, maximum: maximum)
                .foregroundColor(colorFor(bpm: bpm))
        }
    }
    
    struct RevCounterBar: Shape {
        
        var bpm: Double
        var minimum: Double
        var maximum: Double
        
        var animatableData: Double {
            get { bpm }
            set { self.bpm = newValue }
        }
        
        func path(in rect: CGRect) -> Path {
            
            var p = Path()
            
            p.addArc(center:
                    CGPoint(x: rect.size.width/2,
                            y: (rect.size.height/2)-12),
                     radius: 150,
                     startAngle: .degrees(120),
                     endAngle: .degrees(120 + (300 * ((bpm - minimum) / (maximum - minimum)))),
                     clockwise: false)

            return p.strokedPath(.init(lineWidth: 20, lineCap: .round))
        }
    }

    struct RevCounterOutline: Shape {
        
        func path(in rect: CGRect) -> Path {
            
            var p = Path()
            
            p.addArc(center:
                        CGPoint(x: rect.size.width/2,
                                y: (rect.size.height/2)-12),
                     radius: 150,
                     startAngle: .degrees(120),
                     endAngle: .degrees(60),
                     clockwise: false)

            return p.strokedPath(.init(lineWidth: 20, lineCap: .round))
        }
    }
    
    private func colorFor(bpm: Double) -> Color {
        
        let percent = (bpm / maximum) * 100
        var color: Color = .black
        hrZones.forEach { (zone) in
            if percent <= zone.maxPercent && percent >= zone.minPercent {
                color = zone.color
            }
        }
        
        return color
    }
    
    private func blurFor(bpm: Double) -> CGFloat {
        
        let percent = (bpm / maximum) * 100
        var blur: CGFloat = 0
        
        hrZones.forEach { (zone) in
            if percent <= zone.maxPercent && percent >= zone.minPercent {
                blur = zone.blur
            }
        }
        
        return blur
    }
}
