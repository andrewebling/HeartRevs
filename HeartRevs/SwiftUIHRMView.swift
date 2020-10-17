//
//  SwiftUIHRMView.swift
//  HeartRevs
//
//  Created by Andrew Ebling on 16/10/2020.
//  Copyright © 2020 Andrew Ebling. All rights reserved.
//

import SwiftUI

struct HeartRateZone {
    let minBPM: Double
    let maxBPM: Double
    let color: Color
    let blur: CGFloat
}

struct SwiftUIHRMView: View {
    
    private let heartSFSymbolName = "heart"
    @State var showingSettings = false
    
    @State private var bpm: Double = 60 {
        mutating didSet {
            bpmIncreasing = oldValue < bpm
        }
    }
    @State private var animationAmount: CGFloat = 1
    var bpmIncreasing = true
    
    @State private var flipped = false
    
    private let maxHR = 190
    private let maxAnimationAmount = CGFloat(1.04)
    private let pulseDutyCycle = 0.15
    private let secondsInMinute = 60.0
    private let hrZones = [
        HeartRateZone(minBPM: 0, maxBPM: 140, color: .green, blur: 0),
        HeartRateZone(minBPM: 140, maxBPM: 175, color: .yellow, blur: 3),
        HeartRateZone(minBPM: 175, maxBPM: 190, color: .red, blur: 8)
    ]
    
    func colorFor(bpm: Double) -> Color {
        
        var color: Color = .black
        hrZones.forEach { (zone) in
            if bpm <= zone.maxBPM && bpm >= zone.minBPM {
                color = zone.color
            }
        }
        return color
    }
    
    func blurFor(bpm: Double) -> CGFloat {
        var blur: CGFloat = 0
        
        hrZones.forEach { (zone) in
            if bpm <= zone.maxBPM && bpm >= zone.minBPM {
                blur = zone.blur
            }
        }
        
        return blur
    }
    
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
                    FlipView(front: CardFace(title: String(Int(bpm)), subTitle: "BPM", background: Color(UIColor.systemBackground)),
                             back: CardFace(title: String(Int(100 * Double(bpm) / Double(maxHR))), subTitle: "%", background: Color(UIColor.systemBackground)), showBack: $flipped)
                    
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
                .onTapGesture {
                    withAnimation {
                        self.flipped.toggle()
                    }
                }
                RevCounterOutline()
                    .foregroundColor(Color(UIColor.secondarySystemFill))
                if bpmIncreasing {
                    RevCounter(bpm: $bpm)
                        .foregroundColor(colorFor(bpm: bpm))
                        .brightness(0.2)
                        .blur(radius: blurFor(bpm: bpm))
                }
                RevCounter(bpm: $bpm)
                    .foregroundColor(colorFor(bpm: bpm))
                
                
            }
            .onAppear {
                withAnimation(.easeIn(duration: pulseDutyCycle * secondsInMinute / (bpm))) {
                    animationAmount = maxAnimationAmount
                }
            }
            
            Slider(value: $bpm.animation(.linear), in: 60...190, step: 1)
                .padding()
        }
    }
}

struct RevCounter: Shape {
    @Binding var bpm: Double
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

// Currently in SwiftUI there is no way to set a completion block to execute code on
// completion of an animation. Workaround is taken from
// https://www.avanderlee.com/swiftui/withanimation-completion-callback/

/// An animatable modifier that is used for observing animations for a given animatable value.
struct AnimationCompletionObserverModifier<Value>: AnimatableModifier where Value: VectorArithmetic {

    /// While animating, SwiftUI changes the old input value to the new target value using this property. This value is set to the old value until the animation completes.
    var animatableData: Value {
        didSet {
            notifyCompletionIfFinished()
        }
    }

    /// The target value for which we're observing. This value is directly set once the animation starts. During animation, `animatableData` will hold the oldValue and is only updated to the target value once the animation completes.
    private var targetValue: Value

    /// The completion callback which is called once the animation completes.
    private var completion: () -> Void

    init(observedValue: Value, completion: @escaping () -> Void) {
        self.completion = completion
        self.animatableData = observedValue
        targetValue = observedValue
    }

    /// Verifies whether the current animation is finished and calls the completion callback if true.
    private func notifyCompletionIfFinished() {
        guard animatableData == targetValue else { return }

        /// Dispatching is needed to take the next runloop for the completion callback.
        /// This prevents errors like "Modifying state during view update, this will cause undefined behavior."
        DispatchQueue.main.async {
            self.completion()
        }
    }

    func body(content: Content) -> some View {
        /// We're not really modifying the view so we can directly return the original input value.
        return content
    }
}

extension View {

    /// Calls the completion handler whenever an animation on the given value completes.
    /// - Parameters:
    ///   - value: The value to observe for animations.
    ///   - completion: The completion callback to call once the animation completes.
    /// - Returns: A modified `View` instance with the observer attached.
    func onAnimationCompleted<Value: VectorArithmetic>(for value: Value, completion: @escaping () -> Void) -> ModifiedContent<Self, AnimationCompletionObserverModifier<Value>> {
        return modifier(AnimationCompletionObserverModifier(observedValue: value, completion: completion))
    }
}

// end of animation completion workaround
struct SwiftUIHRMView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIHRMView()
    }
}
