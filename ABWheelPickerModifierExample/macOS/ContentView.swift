//
//  ContentView.swift
//  ABWheelPickerModifierExample (macOS)
//
//  Created by Abenx on 2020/10/28.
//

import SwiftUI
import ABWheelPickerModifier

struct ContentView: View {
    var wheelPickerModifierData = ABWheelPickerModifierData(initValue: 320)
    
    var body: some View {
        self.wheelPickerModifierData.minimumValue = 30
        self.wheelPickerModifierData.maximumValue = 7500
        self.wheelPickerModifierData.step = 30
        return HStack(spacing: 80) {
            Image(systemName: "timelapse")
                .resizable()
                .modifier(ABWheelPickerModifier(ABWheelPickerModifierData().setRange(-3600, 3600), dragGestureOnChanged: { _ in
                }))
                .frame(width: 80, height: 80, alignment: .center)

            WheelPickerView(wheelPickerModifierData: self.wheelPickerModifierData)
                .frame(width: 180, height: 180, alignment: .center)
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
