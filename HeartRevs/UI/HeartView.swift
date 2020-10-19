//
//  HeartView.swift
//  HeartRevs
//
//  Created by Andrew Ebling on 19/10/2020.
//  Copyright © 2020 Andrew Ebling. All rights reserved.
//

import SwiftUI

struct HeartView: View {
    
    private let heartSFSymbolName = "heart"
    
    @Binding var flipped: Bool
    @Binding var bpm: Double
    @Binding var maxHR: Int
    @State var animationAmount: CGFloat = 1.0
    
    private let maxAnimationAmount = CGFloat(1.04)
    private let pulseDutyCycle = 0.15
    private let secondsInMinute = 60.0
    private let heartSymbolSize = CGFloat(200)
    private let heartColor = Color.red

    var body: some View {
        ZStack {
            FlipView(front: CardFace(title: " \(Int(bpm)) ",
                                     subTitle: "BPM",
                                     background: Color(UIColor.systemBackground)),
                     
                     back: CardFace(title: String(Int(100 * Double(bpm) / Double(maxHR))),
                                    subTitle: "%",
                                    background: Color(UIColor.systemBackground)),
                     
                     showBack: $flipped)
            
            Image(systemName: heartSFSymbolName)
                .font(.system(size: heartSymbolSize))
                .foregroundColor(heartColor)
                .overlay(
                    Image(systemName: heartSFSymbolName)
                        .font(.system(size: heartSymbolSize))
                        .foregroundColor(heartColor)
                        .scaleEffect(animationAmount)
                        .onAnimationCompleted(for: animationAmount) {
                            if(animationAmount == maxAnimationAmount) {
                                withAnimation(.easeOut(duration: (1 - pulseDutyCycle) * secondsInMinute / (bpm))) {
                                    animationAmount = 1.0
                                }
                            }else {
                                withAnimation(.easeIn(duration: pulseDutyCycle * secondsInMinute / (bpm))) {
                                    animationAmount = maxAnimationAmount
                                }
                            }
                        }
                )
                .rotation3DEffect(self.flipped ? Angle(degrees: 180) : Angle(degrees: 0), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))

        }
        .onAppear {
            withAnimation(.easeIn(duration: pulseDutyCycle * secondsInMinute / (bpm))) {
                animationAmount = maxAnimationAmount
            }
        }
    }
}
