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
