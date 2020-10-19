//
//  SwiftUIHRMView.swift
//  HeartRevs
//
//  Created by Andrew Ebling on 16/10/2020.
//  Copyright © 2020 Andrew Ebling. All rights reserved.
//

import SwiftUI

struct SwiftUIHRMView: View {
    
    @EnvironmentObject var hrmReceiver: HRMReaderReceiver
    
    @State var showingSettings = false
    @State private var flipped = false
    @State private var maxHR = 190
    @State private var sliderShowing = false
    
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
                
                HeartView(flipped: $flipped,
                          bpm: $hrmReceiver.bpm,
                          maxHR: $maxHR)
                    .onTapGesture {
                        withAnimation {
                            self.flipped.toggle()
                        }
                    }
                
                RevCounter(bpm: $hrmReceiver.bpm.animation(.linear))
            }
            
            if sliderShowing {
                Slider(value: $hrmReceiver.bpm.animation(.linear),
                       in: 60...190,
                       step: 1)
                    .transition(.move(edge: .bottom))
                    .padding()
            }
        }
        .onTapGesture(count: 2) {
            withAnimation {
                self.sliderShowing.toggle()
            }
        }
    }
}

// end of animation completion workaround
struct SwiftUIHRMView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIHRMView()
    }
}
