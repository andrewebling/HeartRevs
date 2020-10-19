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
    
    @State private var animationAmount: CGFloat = 1
    @State var showingSettings = false
    @State private var flipped = false
    
    @State private var maxHR = 190

    

    
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
