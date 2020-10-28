//
//  ContentView.swift
//  ABWheelPickerModifierExample (iOS)
//
//  Created by Abenx on 2020/10/28.
//

import SwiftUI
import ABWheelPickerModifier

struct ContentView: View {
    var wheelPickerModifierData = ABWheelPickerModifierData(initAngle: 720)
    
    var body: some View {
        VStack(spacing: 80) {
            WheelPickerView(wheelPickerModifierData: self.wheelPickerModifierData)
                .frame(width: 80, height: 80, alignment: .center)
                .padding()

            WheelPickerView()
                .frame(width: 120, height: 120, alignment: .center)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
