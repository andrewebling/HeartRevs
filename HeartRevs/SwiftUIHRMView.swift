//
//  SwiftUIHRMView.swift
//  HeartRevs
//
//  Created by Andrew Ebling on 16/10/2020.
//  Copyright © 2020 Andrew Ebling. All rights reserved.
//

import SwiftUI

struct SwiftUIHRMView: View {
    
    private let heartSFSymbolName = "heart"
    
    @EnvironmentObject var hrmReceiver: HRMReaderReceiver
    
    @State private var animationAmount: CGFloat = 1
    @State var showingSettings = false
    @State private var flipped = false
    
    private let maxHR = 190
    private let maxAnimationAmount = CGFloat(1.04)
    private let pulseDutyCycle = 0.15
    private let secondsInMinute = 60.0
    

    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    self.showingSettings.toggle()
                }, label: {
                    Image(systemName: "gear")
                }).sheet(isPresented: $showingSettings, content: {
                    SettingsView()
                })
                .accentColor(Color(UIColor.label))
                .padding()
            }
            ZStack {

                ZStack {
                    FlipView(front: CardFace(title: " \(Int(self.hrmReceiver.bpm)) ", subTitle: "BPM", background: Color(UIColor.systemBackground)),
                             back: CardFace(title: String(Int(100 * Double(self.hrmReceiver.bpm) / Double(maxHR))), subTitle: "%", background: Color(UIColor.systemBackground)), showBack: $flipped)
                    
                    Image(systemName: heartSFSymbolName)
                        .font(.system(size: 200))
                        .foregroundColor(.red)
                        .overlay(
                            Image(systemName: heartSFSymbolName)
                                .font(.system(size: 200))
                                .foregroundColor(.red)
                                .scaleEffect(animationAmount)
                                .onAnimationCompleted(for: animationAmount) {
                                    if(animationAmount == maxAnimationAmount) {
                                        withAnimation(.easeOut(duration: (1 - pulseDutyCycle) * secondsInMinute / (self.hrmReceiver.bpm))) {
                                            animationAmount = 1.0
                                        }
                                    }else {
                                        withAnimation(.easeIn(duration: pulseDutyCycle * secondsInMinute / (self.hrmReceiver.bpm))) {
                                            animationAmount = maxAnimationAmount
                                        }
                                    }
                                }
                        )
                        .rotation3DEffect(self.flipped ? Angle(degrees: 180) : Angle(degrees: 0), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
  
                }
                .onTapGesture {
                    withAnimation {
                        self.flipped.toggle()
                    }
                }
                RevCounter()
            }
            .onAppear {
                withAnimation(.easeIn(duration: pulseDutyCycle * secondsInMinute / (self.hrmReceiver.bpm))) {
                    animationAmount = maxAnimationAmount
                }
            }
            
            Slider(value: $hrmReceiver.bpm.animation(.linear), in: 60...190, step: 1)
                .padding()
        }
    }
}






// end of animation completion workaround
struct SwiftUIHRMView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIHRMView()
    }
}
